function exploreProblems

% Include path for visualization function
includePath = '/Users/javimazzaf/Documents/work/matlabCode/imageVisualizationTools/';
addpath(includePath);
cleanObject = onCleanup(@() rmpath(includePath));

imPath = '/Users/javimazzaf/Dropbox (Biophotonics)/Francois/310117TOTM/';
imName = 'T.M. 0.01 1.tif';

oriIm = imread(fullfile(imPath,imName));
[oriIm, ~] = resetScale(oriIm(:,:,1));

load(fullfile(imPath,'TuftNumbers',[imName '.mat']),'tuftsMask')

load(fullfile(imPath, 'VasculatureNumbers', [imName '.mat']),'smoothVessels');

resIm = cat(3, uint8(tuftsMask) .* oriIm,oriIm, oriIm);

visualizeMultiImages(resIm,{smoothVessels;oriIm},19);
    
end