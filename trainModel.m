readConfig

masterFolder = '/yourImagesFolder/';

myFiles = getImageList(masterFolder);

warnStruct = warning('Off');
mkdir(masterFolder, 'Masks')
mkdir(masterFolder, 'ONCenter')
warning(warnStruct)

computeMaskAndCenter(masterFolder, myFiles);

data = [];
res  = [];

rng(1);

offSet = [0 0];

blockSize = [0 0];

for it = 1:numel(myFiles)
    
    fname = myFiles{it};
    
    oImage = imread(fullfile(masterFolder, fname));
    oImage = oImage(:,:,1);
    
    % Make 8 bits
    oImage = im2uint8(oImage);
    
    load(fullfile(masterFolder, 'Masks',    [myFiles{it} '.mat']), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', [myFiles{it} '.mat']), 'thisONCenter');
    
    [maskStats, maskNoCenter] = processMask(thisMask, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    manualSegmentationFile = fullfile(masterFolder, 'ManualSegmentations',[myFiles{it} '.tif']);
    
    if ~exist(manualSegmentationFile, 'file'), continue, end
    
    manualMask = logical(imread(manualSegmentationFile));
    
    %Adjust sizes
    nRows = min([size(manualMask,1),size(oImage,1), size(thisMask,1)]);
    nCols = min([size(manualMask,2),size(oImage,2), size(thisMask,2)]);
    
    manualMask    = resetScale(manualMask(1:nRows,1:nCols));
    oImage        = resetScale(oImage(      1:nRows,1:nCols));
    thisMask      = resetScale(thisMask(    1:nRows,1:nCols));
    validMask     = resetScale(validMask(    1:nRows,1:nCols));
    maskNoCenter  = resetScale(maskNoCenter(    1:nRows,1:nCols));
    
    retinaDiam = computeRetinaSize(thisMask, thisONCenter);
    
    blockSize(it,:) = ceil(retinaDiam * tufts.blockSizeFraction) * [1 1];
    
    [blocks, indBlocks] = getBlocks(oImage, blockSize(it,:), offSet);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & manualMask, tufts.blocksInMaskPercentage, offSet);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~manualMask, tufts.blocksInMaskPercentage, offSet);
    
    blockFeatures = computeBlockFeatures(oImage,maskNoCenter, thisMask, indBlocks,trueBlocks,falseBlocks, offSet, thisONCenter);
    
    data = [data;blockFeatures];
    res  = [res;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
    
    disp(it)
end

save(fullfile(masterFolder, 'trainingSet.mat'),'data','res','blockSize')

%% Build and save model
load(fullfile(masterFolder, 'trainingSet.mat'),'data','res')
model = fitcdiscr(data,res,'DiscrimType','quadratic','Cost',tufts.classCost,'Prior','empirical');
save(fullfile(masterFolder, 'model.mat'),'model','-v7.3')