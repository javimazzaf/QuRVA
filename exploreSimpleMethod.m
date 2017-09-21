function exploreSimpleMethod

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

oriIm = double(oriIm(:,:,1));

oriIm  = resetScale(oriIm);

% oriIm = mat2gray(oriIm);

oriIm = imadjust(mat2gray(oriIm));

load(fullfile(imPath,'Masks',[imName '.mat']),'thisMask')
[thisMask, scaleFactor]  = resetScale(thisMask);

load(fullfile(imPath,'ONCenter',[imName '.mat']),'thisONCenter')
thisONCenter = thisONCenter/scaleFactor;


%%

[~,mnIm]  = imStd(oriIm, 2);

grad  = gradient(oriIm); 
grad2 = del2(oriIm);

grad  = imStd(grad, 2) ./ mnIm;
grad2 = imStd(grad2, 2) ./ mnIm;

% visualizeMultiImages(oriIm,{grad;grad2},100);

%%

% resIm = cat(3, uint8(tuftsMask) .* oriIm,oriIm, oriIm);

% fun = @(x) iqr5(x); 
% B = nlfilter(oriIm, [5 5], fun);

% tic
% B = colfilt(oriIm,[5 5],'sliding',@iqrDisk5);
% toc

hdisk = fspecial('disk',5) > 0;

mn = filter2(hdisk,oriIm) / sum(hdisk(:)) .* thisMask;
mn2 = filter2(hdisk,oriIm.^2) / sum(hdisk(:)) .* thisMask;

sd = sqrt(mn2 - mn.^2) .* thisMask;

contrast = sd ./ mn;

hBig = fspecial('disk',10) > 0;
mnBig = filter2(hBig,oriIm) / sum(hBig(:)) .* thisMask;

% mnBig = oriIm;
mnBig = mnBig / prctile(mnBig(:),99.9);

% [smoothed, ~] = localBrightness(oriIm, thisMask, thisONCenter);
% 
% mnBig

msk = (contrast < 0.1) & (mnBig > 0.5);

% nearObj = bwdist(msk);
% 
% mask2 = (contrast < 0.2) & (mnBig > 0.4) & (nearObj < 20);
% 
% msk = msk | mask2;

oriIm = imadjust(oriIm);
oriIm = uint8(oriIm * 255);

rgb = cat(3, uint8(~msk) .* oriIm, oriIm, oriIm);

visualizeMultiImages(rgb,{mnBig;contrast;grad;grad2},100);
    
end

function r = iqrDisk5(im)

r = iqr(im(logical([0 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 0]),:));

end

function [sd,mn] = imStd(inIm, radio)
hdisk = fspecial('disk',radio) > 0;

mn = filter2(hdisk,inIm) / sum(hdisk(:));
mn2 = filter2(hdisk,inIm.^2) / sum(hdisk(:));

sd = sqrt(mn2 - mn.^2);
end
