clear
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/ImageCollection/';
fileName='33G-conv.tif';

load('myNetwork.mat')

thisImage=imread([masterFolder fileName]);
redImage=thisImage(:,:,1);

%% Load Mask and Center
load(fullfile(masterFolder, 'Masks',    [fileName '.mat']), 'thisMask');
load(fullfile(masterFolder, 'ONCenter', [fileName '.mat']), 'thisONCenter');

if strcmp(class(redImage), 'uint16')
        redImage=uint8(double(redImage)/65535*255);
end

[maskStats, maskNoCenter] = processMask(thisMask, redImage, thisONCenter);

% redImage=imresize(redImage, [4000, 4000]);
% thisMask=imresize(thisMask, [4000, 4000]);
% maskNoCenter=imresize(maskNoCenter, [4000, 4000]);
    
[blocks, ind] = getBlocks(redImage, [28 28], [0 0]);

inMaskBlocks= getBlocksInMask(ind, thisMask.*maskNoCenter, 70, [0 0]);
    
for itBlock=1:size(inMaskBlocks, 1)
     thisBlock=uint8(mat2gray(blocks(:,:,inMaskBlocks(itBlock,1), inMaskBlocks(itBlock,2)))*255);
     YTest(itBlock) = classify(convnet,thisBlock);
     
end
%%
blockResult=grp2idx(YTest);
tuftBlocks=find(blockResult==2);
newImage=blocksToMask(size(redImage), ind, [inMaskBlocks(tuftBlocks, 1) inMaskBlocks(tuftBlocks, 2)]);

% imshow(cat(3, newImage*100, redImage, newImage))
%%

[vesselSkelMask, brchPts, smoothVessels, endPts]=getVacularNetwork(thisMask, redImage);
imshow(cat(3, newImage.*smoothVessels*200, redImage, newImage))
