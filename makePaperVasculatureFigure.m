clear 

readConfig;

myFiles = getImageList(masterFolder);

%% Prepare mask and Center
computeMaskAndCenter(masterFolder, myFiles);

 %% Read image
thisImage=imread(fullfile(masterFolder, myFiles{6}));
redImage=thisImage(:,:,1);

%% Load Mask and Center
load(fullfile(masterFolder, 'Masks',    [myFiles{6} '.mat']), 'thisMask');
load(fullfile(masterFolder, 'ONCenter', [myFiles{6} '.mat']), 'thisONCenter');

[maskStats, maskNoCenter] = processMask(thisMask, redImage, thisONCenter);

[vesselSkelMask, brchPts, smoothVessels]=getVacularNetwork(thisMask, redImage);

%%

% niceImage=cat(3, redImage+uint8(imdilate(vesselSkelMask, strel('disk', 1)).*255),...
%                 redImage+uint8(imdilate(brchPts, strel('disk',3)).*255),...
%                 redImage);

niceImage = imoverlay(imoverlay(redImage,imdilate(vesselSkelMask,strel('disk', 1)),'y'),imdilate(brchPts,strel('disk', 2)),'r');

            
niceImage = imcrop(niceImage, maskStats.BoundingBox);
niceImage = double(niceImage) / double(max(niceImage(:)));

redImage       = imcrop(redImage, maskStats.BoundingBox);
vesselSkelMask = imcrop(vesselSkelMask, maskStats.BoundingBox);
brchPts        = imcrop(brchPts, maskStats.BoundingBox);

imshow(niceImage,[])

h = imrect(gca);

origROI = imcrop(redImage, h.getPosition);
skelROI = imcrop(vesselSkelMask, h.getPosition);
brchROI = imcrop(brchPts, h.getPosition);

imageROI = imoverlay(imoverlay(origROI,imdilate(skelROI,strel('disk', 1)),'y'),imdilate(brchROI,strel('disk', 2)),'r');

rectPositions = h.getPosition;
imshow(niceImage,[], 'Border', 'Tight')
rectangle('Position', rectPositions, 'EdgeColor', 'w', 'LineWidth', 2, 'LineStyle', '-')

imRGB = print('-RGBImage');
% print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/VasculatureNetwork.png');
imwrite(imRGB, '/Users/javimazzaf/Dropbox (Biophotonics)/Manuscript/Figures/VasculatureNetwork/fullsizeSkeleton.png', 'png')


% imwrite(imageROI, '/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/VasculatureNetworkZoomIn.tif', 'TIF')
imwrite(imageROI, '/Users/javimazzaf/Dropbox (Biophotonics)/Manuscript/Figures/VasculatureNetwork/zoomInSkeleton.png', 'png')

