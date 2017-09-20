% function exploreProblems

% Include path for visualization function
includePath = '/Users/javimazzaf/Documents/work/matlabCode/imageVisualizationTools/';
addpath(includePath);
cleanObject = onCleanup(@() rmpath(includePath));

imPath = '../Anonymous/';
imName = 'Image002.jpg';

% imPath = '/Users/javimazzaf/Dropbox (Biophotonics)/Francois/310117TOTM/';
% imName = 'T.M. 0.01 2.tif';


% imPath = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/';
% imName = '1_B_original.tif';


oriIm = imread(fullfile(imPath,imName));

oriIm = oriIm(:,:,1);

oriIm  = double(resetScale(oriIm));

% oriIm = imadjust(mat2gray(oriIm));
oriIm = mat2gray(oriIm);

load(fullfile(imPath,'Masks',[imName '.mat']),'thisMask')
thisMask  = resetScale(thisMask);

% resIm = cat(3, uint8(tuftsMask) .* oriIm,oriIm, oriIm);

hdisk = fspecial('disk',2) > 0;

mn = filter2(hdisk,oriIm) / sum(hdisk(:)) .* thisMask;
mn2 = filter2(hdisk,oriIm.^2) / sum(hdisk(:)) .* thisMask;

sd = sqrt(mn2 - mn.^2) .* thisMask;

contrast = sd ./ mn;

hBig = fspecial('disk',10) > 0;
mnBig = filter2(hBig,oriIm) / sum(hBig(:)) .* thisMask;


msk = (contrast < 0.1) & (mnBig > 0.5);

nearObj = bwdist(msk);

mask2 = (contrast < 0.2) & (mnBig > 0.4) & (nearObj < 20);

msk = msk | mask2;

rgb = cat(3, uint8(~msk) .* uint8(oriIm * 255),uint8(oriIm * 255), uint8(oriIm * 255));
% imshow(imoverlay(oriIm,msk,'m'))

visualizeMultiImages(rgb,{sd;mnBig;contrast;msk},100);
    
% end
