clear
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/ImageCollection/';

load('myNetwork.mat')
thisImage=imread('/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/ImageCollection/2. TRAP.jpg');
redImage=thisImage(:,:,1);

%% Load Mask and Center
load(fullfile(masterFolder, 'Masks',    ['2. TRAP.jpg.mat']), 'thisMask');
load(fullfile(masterFolder, 'ONCenter', ['2. TRAP.jpg.mat']), 'thisONCenter');

[maskStats, maskNoCenter] = processMask(thisMask, redImage, thisONCenter);

% redImage=imresize(redImage, [4000, 4000]);
% thisMask=imresize(thisMask, [4000, 4000]);
% maskNoCenter=imresize(maskNoCenter, [4000, 4000]);
rowDisplacements=0:14:14;
colDisplacements=0:14:14;
k=0;
for row=1:numel(rowDisplacements)
    for col=1:numel(colDisplacements)
        k=k+1
        [blocks, ind] = getBlocks(redImage, [28 28], [rowDisplacements(row) colDisplacements(col)]);
        inMaskBlocks= getBlocksInMask(ind, thisMask.*maskNoCenter, 70, [rowDisplacements(row) colDisplacements(col)]);
        
        for itBlock=1:size(inMaskBlocks, 1)
             thisBlock=uint8(mat2gray(blocks(:,:,inMaskBlocks(itBlock,1), inMaskBlocks(itBlock,2)))*255);
             YTest(itBlock) = classify(convnet,thisBlock);
        end
        blockResult=grp2idx(YTest);
        tuftBlocks=find(blockResult==2);
        newImage(:,:,k)=blocksToMask(size(redImage), ind, [inMaskBlocks(tuftBlocks,1) inMaskBlocks(tuftBlocks,2)], [rowDisplacements(row) colDisplacements(col)]);

        clear blocks ind inMaskBlocks YTest blockResult tuftBlocks
    end
end

%%
tuftMask= sum(newImage, 3)==4;
tuftMask2=bwareaopen(tuftMask, 28^2);

[vesselSkelMask, brchPts, smoothVessels, endPts]=getVacularNetwork(thisMask, redImage);

imshow(cat(3, redImage, uint8(tuftMask2.*smoothVessels)*155, redImage))

