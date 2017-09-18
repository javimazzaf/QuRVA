function exploreProblems

% Include path for visualization function
includePath = '/Users/javimazzaf/Documents/work/matlabCode/imageVisualizationTools/';
addpath(includePath);
cleanObject = onCleanup(@() rmpath(includePath));

imPath = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/';
imName = '10_C_original.tif';

oriIm = imread(fullfile(imPath,imName));
[oriIm, ~] = resetScale(oriIm(:,:,1));

load(fullfile(imPath,'TuftNumbers',[imName '.mat']),'tuftsMask')

load(fullfile(imPath, 'VasculatureNumbers', [imName '.mat']),'smoothVessels');

resIm = cat(3, uint8(tuftsMask) .* oriIm,oriIm, oriIm);

visualizeMultiImages(resIm,{smoothVessels;oriIm},19);
    
end