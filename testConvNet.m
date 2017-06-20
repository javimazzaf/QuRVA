clear
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/ImageCollection/';

load('myNetwork.mat')
thisImage=imread('/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/ImageCollection/1. VEH.jpg');
redImage=thisImage(:,:,1);

%% Load Mask and Center
load(fullfile(masterFolder, 'Masks',    ['1. VEH.jpg.mat']), 'thisMask');
load(fullfile(masterFolder, 'ONCenter', ['1. VEH.jpg.mat']), 'thisONCenter');

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
newImage=blocksToMask(size(redImage), ind, [inMaskBlocks(tuftBlocks,1) inMaskBlocks(tuftBlocks,2)], [0 0]);
% for itTuftBlocks=1:numel(tuftBlocks)
%     itTuftBlocks
%     thisImage=blocksToMask(size(redImage), ind, inMaskBlocks(tuftBlocks(itTuftBlocks),:));
% end
% newImage(ind(:,:,inMaskBlocks(40,1), inMaskBlocks(40,2)))=1;
% imshow(imoverlay(newImage, redImage, 'yellow'))

imshow(cat(3, newImage*200, redImage, newImage))
%%

[blocks2, ind2] = getBlocks(redImage, [28 28], [14 14]);

inMaskBlocks2= getBlocksInMask(ind2, thisMask.*maskNoCenter, 70, [14 14]);
    
for itBlock=1:size(inMaskBlocks2, 1)
     thisBlock2=uint8(mat2gray(blocks(:,:,inMaskBlocks2(itBlock,1), inMaskBlocks2(itBlock,2)))*255);
     YTest2(itBlock) = classify(convnet,thisBlock2);
end

%%
blockResult2=grp2idx(YTest2);
tuftBlocks2=find(blockResult2==2);
newImage2=blocksToMask(size(redImage), ind, [inMaskBlocks2(tuftBlocks2,1) inMaskBlocks2(tuftBlocks2,2)], [14 14]);

imshow(cat(3, newImage*200, redImage, newImage2*200))

%%[blocks2, ind2] = getBlocks(redImage, [28 28], [14 14]);
%%

[blocks3, ind3] = getBlocks(redImage, [28 28], [0 14]);


inMaskBlocks3=getBlocksInMask(ind3, thisMask.*maskNoCenter, 70, [0 14]);

    
for itBlock=1:size(inMaskBlocks3, 1)
     thisBlock3=uint8(mat2gray(blocks(:,:,inMaskBlocks3(itBlock,1), inMaskBlocks3(itBlock,2)))*255);
     YTest3(itBlock) = classify(convnet,thisBlock3);
end

%%
blockResult3=grp2idx(YTest3);
tuftBlocks3=find(blockResult3==2);
newImage3=blocksToMask(size(redImage), ind3, [inMaskBlocks3(tuftBlocks3,1) inMaskBlocks3(tuftBlocks3,2)], [0 14]);

%%
[blocks4, ind4] = getBlocks(redImage, [28 28], [14 0]);


inMaskBlocks4=getBlocksInMask(ind4, thisMask.*maskNoCenter, 70, [14 0]);

    
for itBlock=1:size(inMaskBlocks4, 1)
     thisBlock4=uint8(mat2gray(blocks(:,:,inMaskBlocks4(itBlock,1), inMaskBlocks4(itBlock,2)))*255);
     YTest4(itBlock) = classify(convnet,thisBlock4);
end

%%
blockResult4=grp2idx(YTest4);
tuftBlocks4=find(blockResult4==2);
newImage4=blocksToMask(size(redImage), ind4, [inMaskBlocks4(tuftBlocks4,1) inMaskBlocks4(tuftBlocks4,2)], [14 0]);
