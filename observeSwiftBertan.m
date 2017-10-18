function observeSwiftBertan

if ismac
   baseDir = '/Volumes/EyeFolder/';
else
   baseDir = '~/'; 
end

resDir = fullfile(baseDir,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/visualSwift/');
if ~exist('resDir','dir')
    mkdir(resDir);
end

baseOrig = fullfile(baseDir,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/');
dirsOrig = dir(fullfile(baseOrig,'*original.tif'));

baseSwift = fullfile(baseDir,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/');

id = regexp({dirsOrig(:).name},'([0-9]+_[a-zA-Z]+)(?=_original\.tif)','match');

for k = 1:numel(id)
    disp(k)
    
    fileOrig  = fullfile(baseOrig,[id{k}{:} '_original.tif']);
    fileSwift = fullfile(baseSwift,[id{k}{:} '_manual.jpg']);
    fileQuRVA = fullfile(baseOrig,'TuftNumbers',[id{k}{:} '_original.tif.mat']);
    fileMask  = fullfile(baseOrig,'Masks',[id{k}{:} '_original.tif.mat']);
    fileCenter  = fullfile(baseOrig,'ONCenter',[id{k}{:} '_original.tif.mat']);
    
    if ~exist(fileOrig,'file') || ~exist(fileSwift,'file') ||...
       ~exist(fileQuRVA,'file') || ~exist(fileMask,'file')     
        continue
    end
    
    imOrig = imread(fileOrig);
    imOrig = imOrig(:,:,1);
    load(fileQuRVA,'tuftsMask');
    load(fileMask,'thisMask');
    
    load(fileCenter, 'thisONCenter');
    
    maskSwift = imread(fileSwift) > 0;
    
    imshow(imoverlay(imadjust(imOrig),bwperim(thisMask),'m'),[]), hold on
    plot(thisONCenter(1),thisONCenter(2),'*g')
    %Adjust sizes    
    imOrig     = resetScale(imOrig);
    maskSwift  = resetScale(maskSwift);
    tuftsMask  = resetScale(tuftsMask);
    [thisMask, scaleFactor] = resetScale(thisMask);
   
    thisONCenter = thisONCenter/scaleFactor;  
    
    nRows = min([size(imOrig,1),size(maskSwift,1), size(thisMask,1), size(tuftsMask,1)]); 
    nCols = min([size(imOrig,2),size(maskSwift,2), size(thisMask,2), size(tuftsMask,2)]); 
    
    imOrig    = imOrig(1:nRows,1:nCols);
    maskSwift = maskSwift(1:nRows,1:nCols);
    thisMask  = thisMask(1:nRows,1:nCols);
    tuftsMask = tuftsMask(1:nRows,1:nCols);
    
    [~, maskNoCenter] = processMask(thisMask, tuftsMask, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    TP =  maskSwift &  tuftsMask;
    FP = ~maskSwift &  tuftsMask;
    FN =  maskSwift & ~tuftsMask;
    
    restMask = ~TP & ~FP & ~ FN & thisMask;
    
    lowSatLevel = 0.01 + sum(imOrig(:) == min(imOrig(:))) / numel(imOrig);
    highSatLevel = 0.99 - sum(imOrig(:) == max(imOrig(:))) / numel(imOrig);
    
    adjustedImage = imadjust(imOrig,stretchlim(imOrig,[lowSatLevel highSatLevel]));
    
    grayIm  = uint8(restMask) .* adjustedImage;
    
    r = uint8(FP) .* adjustedImage + grayIm;
    g = uint8(TP) .* adjustedImage + grayIm;
    b = uint8(FN) .* adjustedImage + grayIm;
    
    quadNW = cat(3, r, g, b);
    quadNW = imoverlay(quadNW,imdilate(bwperim(validMask),strel('disk',3)),'m');
    
    quadNE = cat(3, adjustedImage, adjustedImage, adjustedImage);
    
    imwrite([quadNW quadNE], fullfile(resDir,[id{k}{:} '.jpg']), 'JPG')
    
end
