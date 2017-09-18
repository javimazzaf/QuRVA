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
    
    trainFile = fullfile(trainPath,[id{:} '_manual.jpg']);
    trainingMask = imread(trainFile) > 0;
    
    load(fullfile(imPath, 'Masks', [imFiles{it} '.mat']), 'thisMask');
    load(fullfile(imPath, 'ONCenter', [imFiles{it} '.mat']), 'thisONCenter');
    load(fullfile(imPath, 'VasculatureNumbers', [imFiles{it} '.mat']),'smoothVessels');
    
    %Adjust sizes
    [thisMask, scaleFactor] = resetScale(thisMask);
    trainingMask = resetScale(trainingMask);
    oImage       = resetScale(oImage);
    smoothVessels= resetScale(smoothVessels);  
    
    thisONCenter = thisONCenter/scaleFactor;
    
    nRows = min([size(trainingMask,1),size(oImage,1), size(thisMask,1), size(smoothVessels,1)]); 
    nCols = min([size(trainingMask,2),size(oImage,2), size(thisMask,2), size(smoothVessels,2)]); 
    
    trainingMask = trainingMask(1:nRows,1:nCols);
    oImage       = oImage(      1:nRows,1:nCols);
    thisMask     = thisMask(    1:nRows,1:nCols);
    smoothVessels= smoothVessels(1:nRows,1:nCols);
    
    [~, maskNoCenter] = processMask(thisMask, oImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    retinaDiam(it) = computeRetinaSize(thisMask, thisONCenter);
    
    blockSize(it,:) = ceil(retinaDiam(it) * tufts.blockSizeFraction) * [1 1];

    [~, indBlocks] = getBlocks(oImage, blockSize(it,:), offSet);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & trainingMask, tufts.blocksInMaskPercentage, offSet);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~trainingMask, tufts.blocksInMaskPercentage, offSet);

    blockFeatures = computeBlockFeatures(oImage,maskNoCenter, thisMask, indBlocks,trueBlocks,falseBlocks, offSet, thisONCenter, smoothVessels);

    data = [data;blockFeatures];
    res  = [res;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
 
    disp(it)
end

versionInfo.dayTag = datestr(now,'yyyymmdd_HH_MM');

save(fileTrainingSet,'data','res','blockSize','retinaDiam','versionInfo')

model = fitcdiscr(data,res,'DiscrimType','quadratic','Cost',tufts.classCost,'Prior','empirical');

save(fileModel,'model','-v7.3')

end