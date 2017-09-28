imPath = '../Anonymous/';
% imPath = '/Users/javimazzaf/Dropbox (Biophotonics)/Francois/310117TOTM/';


maskFiles = dir(fullfile(imPath,'Masks','*.mat'));
maskFiles = {maskFiles(:).name};

allFiles = cellfun(@(x) x(1:end-4),maskFiles,'UniformOutput',false);

processFolder(imPath,allFiles(1:20));
% processFolder(imPath,allFiles(21:2:end)); 

% rawImage = imread(fullfile(imPath,allFiles{4}));
% load(fullfile(imPath,'Masks',maskFiles{4}));
% 
% rawImage = resetScale(rawImage(:,:,1));
% 
% thisMask = resetScale(thisMask);
% 
% [bgMean,bgStd] = getRobustLocalBackground(rawImage, thisMask);
% 
% rawImage = rawImage.*uint8(thisMask);
% rawImageNorm = mat2gray(double(rawImage));
% 
% mask = (rawImageNorm > (bgMean + 3*bgStd));
% 
% figure;imshow(mask & thisMask,[])
