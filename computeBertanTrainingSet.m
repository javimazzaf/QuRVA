% We used for generating the training set from
% Bertan Images.
%
% imPath: path where raw images are stored
% trainPath: path where segmented masks are stored
% imFiles: selection of images used to train
% fileTrainingSet: file name where to store the training set

function computeBertanTrainingSet(imPath,trainPath,imFiles,fileTrainingSet)

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
    
    [~, maskNoCenter] = processMask(thisMask, oImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    retinaDiam(it) = computeRetinaSize(thisMask, thisONCenter);
    
    blockSize(it,:) = ceil(retinaDiam(it) * tufts.blockSizeFraction) * [1 1];

    [~, indBlocks] = getBlocks(oImage, blockSize(it,:), offSet);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & trainingMask, tufts.blocksInMaskPercentage, offSet);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~trainingMask, tufts.blocksInMaskPercentage, offSet);
    
    blockFeatures = computeBlockFeatures(oImage,maskNoCenter, thisMask, indBlocks,trueBlocks,falseBlocks, offSet, thisONCenter);

    data = [data;blockFeatures];
    res  = [res;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
 
    imRGB = cat(3,uint8(~trainingMask) .* uint8(sImage * 255), uint8(sImage * 255), uint8(sImage * 255));
    imRGB = imoverlay(imRGB,imdilate(bwperim(validMask),strel('disk',3)),'m');
    
    imwrite(imRGB,fullfile(verifDir,[fname(1:end-3) 'jpg']));
    
    disp([num2str(it) ': ' fname])
end

versionInfo.dayTag = datestr(now,'yyyymmdd_HH_MM');

save(fileTrainingSet,'data','res','blockSize','retinaDiam','versionInfo')

end