readConfig

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

myFiles = dir(fullfile(masterFolder, 'Masks','*.mat'));
myFiles = {myFiles(:).name};

data1 = [];
res1  = [];

data2 = [];
res2  = [];

% Repeatability
rng(1);

offSet = [0 0];

blockSize = [0 0];

for it = 1:numel(myFiles)
    
    disp(it)
    
    fname = myFiles{it};
    fname = fname(1:end-4);
    
    consensusFilePath = fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it});
    if ~exist(consensusFilePath, 'file'), continue, end
    
    oImage = imread(fullfile(masterFolder, fname));
    oImage = oImage(:,:,1);

    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    
    [maskStats, maskNoCenter] = processMask(thisMask, oImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    load(consensusFilePath,'allMasks');
    consensusMask = sum(allMasks, 3) >= consensus.reqVotes;

    retinaDiam(it) = computeRetinaSize(thisMask, thisONCenter);
    
    blockSize(it,:) = ceil(retinaDiam(it) * tufts.blockSizeFraction) * [1 1];
    
    [blocks, indBlocks] = getBlocks(oImage, blockSize(it,:), offSet);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & consensusMask, tufts.blocksInMaskPercentage, offSet);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~consensusMask, tufts.blocksInMaskPercentage, offSet);

    blockFeatures = computeBlockFeatures(oImage,maskNoCenter, thisMask, indBlocks,trueBlocks,falseBlocks, offSet, thisONCenter);
      
    if it <= 7
        data1 = [data1;blockFeatures];
        res1 = [res1;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
    elseif it <= 14
        data2 = [data2;blockFeatures];
        res2 = [res2;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
    else %15-20
        data1 = [data1;blockFeatures];
        res1 = [res1;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
        data2 = [data2;blockFeatures];
        res2 = [res2;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
    end
      
end

versionInfo.dayTag = datestr(now,'yyyymmdd_HH_MM');

save(fullfile(masterFolder, 'trainingSetPaper.mat'),'data1','res1','data2','res2','blockSize','retinaDiam','versionInfo')





