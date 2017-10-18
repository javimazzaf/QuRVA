function trainQuRVA(imPath,trainPath,imFiles,fileTrainingSet,fileModel)

readConfig

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

data = [];
res  = [];

offSet = [0 0];

blockSize = [0 0];

[modelDir,~,~] = fileparts(fileModel);

verifDir = fullfile(modelDir,'verification');
if ~exist(verifDir,'dir'), mkdir(verifDir), end

for it = 1:numel(imFiles)
    
    fname = imFiles{it};
    
    oImage = imread(fullfile(imPath, fname));
    oImage = oImage(:,:,1);
    %% Make 8 bits
    if strcmp(class(oImage), 'uint16')
        oImage = uint8(double(oImage)/65535*255);
    end
    
    id = regexp(fname,'([0-9]+_[a-zA-Z]+)(?=_original\.tif)','match');
    
    trainFile = fullfile(trainPath,[id{:} '_manual.jpg']);
    trainingMask = imread(trainFile) > 100;
    
    load(fullfile(imPath, 'Masks', [imFiles{it} '.mat']), 'thisMask');
    load(fullfile(imPath, 'ONCenter', [imFiles{it} '.mat']), 'thisONCenter');
    
    %Adjust sizes
    nRows = min([size(trainingMask,1),size(oImage,1), size(thisMask,1)]); 
    nCols = min([size(trainingMask,2),size(oImage,2), size(thisMask,2)]); 
    
    trainingMask = resetScale(trainingMask(1:nRows,1:nCols));
    oImage       = resetScale(oImage(      1:nRows,1:nCols));
    thisMask     = resetScale(thisMask(    1:nRows,1:nCols));
    
    sImage = overSaturate(oImage);
    
    [~, maskNoCenter] = processMask(thisMask, sImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    retinaDiam(it) = computeRetinaSize(thisMask, thisONCenter);
    
    blockSize(it,:) = ceil(retinaDiam(it) * tufts.blockSizeFraction) * [1 1];

    [~, indBlocks] = getBlocks(sImage, blockSize(it,:), offSet);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & trainingMask, tufts.blocksInMaskPercentage, offSet);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~trainingMask, tufts.blocksInMaskPercentage, offSet);

    blockFeatures = computeBlockFeatures(sImage,maskNoCenter, thisMask, indBlocks,trueBlocks,falseBlocks, offSet, thisONCenter);

    data = [data;blockFeatures];
    res  = [res;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
 
    imRGB = cat(3,uint8(~trainingMask) .* uint8(sImage * 255), uint8(sImage * 255), uint8(sImage * 255));
    imRGB = imoverlay(imRGB,imdilate(bwperim(validMask),strel('disk',3)),'m');
    
    imwrite(imRGB,fullfile(verifDir,fname));
    
    disp(it)
end

versionInfo.dayTag = datestr(now,'yyyymmdd_HH_MM');

save(fileTrainingSet,'data','res','blockSize','retinaDiam','versionInfo')

model = fitcdiscr(data,res,'DiscrimType','quadratic','Cost',tufts.classCost,'Prior','empirical');

save(fileModel,'model','-v7.3')

end