readConfig

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

myFiles = dir(fullfile(masterFolder, 'TuftConsensusMasks','*.mat'));
myFiles = {myFiles(:).name};

data = [];
res  = [];

% Repeatability
rng(1);

offSet = [0 0];

blockSize = [0 0];

for it = 1:numel(myFiles)
    
    fname = myFiles{it};
    fname = fname(1:end-4);
    
    oImage = imread(fullfile(masterFolder, fname));
    oImage = oImage(:,:,1);
    
    %% Make 8 bits
    if strcmp(class(oImage), 'uint16')
        oImage = uint8(double(oImage)/65535*255);
    end

    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    
    [maskStats, maskNoCenter] = processMask(thisMask, oImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    consensusFilePath = fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it});
    
    if ~exist(consensusFilePath, 'file'), continue, end
    
    load(consensusFilePath,'allMasks');
    
    if size(allMasks,3) > 2
       consensusMask = sum(allMasks, 3) >= consensus.reqVotes;
    else
       consensusMask = sum(allMasks, 3) >= 1; % if 1 or 2 evalautors, one vote is enough. 
    end
    
    %Adjust sizes
    nRows = min([size(consensusMask,1),size(oImage,1), size(thisMask,1)]); 
    nCols = min([size(consensusMask,2),size(oImage,2), size(thisMask,2)]); 
    
    consensusMask = resetScale(consensusMask(1:nRows,1:nCols));
    oImage       = resetScale(oImage(      1:nRows,1:nCols));
    thisMask     = resetScale(thisMask(    1:nRows,1:nCols));
    validMask     = resetScale(validMask(    1:nRows,1:nCols));
    
    sImage = overSaturate(oImage);
    
    retinaDiam(it) = computeRetinaSize(thisMask, thisONCenter);
    
    blockSize(it,:) = ceil(retinaDiam(it) * tufts.blockSizeFraction) * [1 1];

    [blocks, indBlocks] = getBlocks(sImage, blockSize(it,:), offSet);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & consensusMask, tufts.blocksInMaskPercentage, offSet);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~consensusMask, tufts.blocksInMaskPercentage, offSet);

    blockFeatures = computeBlockFeatures(sImage,maskNoCenter, thisMask, indBlocks,trueBlocks,falseBlocks, offSet, thisONCenter);

    data = [data;blockFeatures];
    res  = [res;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
 
    disp(it)
end

versionInfo.dayTag = datestr(now,'yyyymmdd_HH_MM');

save(fullfile(masterFolder, 'trainingSet.mat'),'data','res','blockSize','retinaDiam','versionInfo')





