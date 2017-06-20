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

niceImage=cat(3, redImage+uint8(imdilate(vesselSkelMask, strel('disk', 1)).*255),...
                redImage+uint8(imdilate(brchPts, strel('disk',3)).*255),...
                redImage);
            
niceImage=imcrop(niceImage, maskStats.BoundingBox);



imshow(niceImage)
h=imrect(gca)
imageROI=imcrop(niceImage, h.getPosition);

rectPositions=h.getPosition;
imshow(niceImage, 'Border', 'Tight')
rectangle('Position', rectPositions, 'EdgeColor', [1 1 1], 'LineWidth', 2, 'LineStyle', ':')

print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/VasculatureNetwork.png');
imwrite(imageROI, '/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/VasculatureNetworkZoomIn.tif', 'TIF')
%%
[aVascZone]=getAvacularZone(thisMask, vesselSkelMask);
