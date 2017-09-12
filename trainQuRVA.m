function trainQuRVA(imPath,trainPath,imFiles,fileTrainingSet,fileModel)

readConfig

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

data = [];
res  = [];

offSet = [0 0];

blockSize = [0 0];

for it = 1:numel(imFiles)
    
    fname = imFiles{it};
    
    oImage = imread(fullfile(imPath, fname));
    oImage = oImage(:,:,1);
    
    id = regexp(fname,'([0-9]+_[a-zA-Z]+)(?=_original\.tif)','match');
    
    trainFile = fullfile(trainPath,[id '_manual.jpg']);
    trainingMask = imread(trainFile) > 0;
    
    load(fullfile(imPath, 'Masks', imFiles{it}), 'thisMask');
    load(fullfile(imPath, 'ONCenter', imFiles{it}), 'thisONCenter');
    
    [~, maskNoCenter] = processMask(thisMask, oImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    retinaDiam(it) = computeRetinaSize(thisMask, thisONCenter);
    
    blockSize(it,:) = ceil(retinaDiam(it) * tufts.blockSizeFraction) * [1 1];

    [blocks, indBlocks] = getBlocks(oImage, blockSize(it,:), offSet);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & trainingMask, tufts.blocksInMaskPercentage, offSet);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~trainingMask, tufts.blocksInMaskPercentage, offSet);

    blockFeatures = computeBlockFeatures(oImage,maskNoCenter, thisMask, indBlocks,trueBlocks,falseBlocks, offSet, thisONCenter);

    data = [data;blockFeatures];
    res  = [res;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
 
    disp(it)
end

versionInfo.dayTag = datestr(now,'yyyymmdd_HH_MM');

save(fileTrainingSet,'data','res','blockSize','retinaDiam','versionInfo')

model = fitcdiscr(data,res,'DiscrimType','quadratic','Cost',tufts.classCost,'Prior','empirical');

save(fileModel,'model','-v7.3')

end