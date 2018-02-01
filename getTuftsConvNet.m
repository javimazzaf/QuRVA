function tuftsMask=getTuftsConvNet(thisMask, redImage, maskNoCenter, smoothVessels)

load('myNetwork.mat')
rowDisplacements=5:10:26;
colDisplacements=5:10:26;
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

tuftsMask=sum(newImage, 3)>4;
tuftsMask=bwareaopen(tuftsMask, 28^2).*smoothVessels;
