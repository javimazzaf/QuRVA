clear

imageSide=28;

% loads local parameters
readConfig;

mkdir(masterFolder, 'Global')
mkdir(masterFolder, 'TrainingDB')

%% Get file names
myFiles = dir(fullfile(masterFolder, '*.jpg'));
myFiles = {myFiles(:).name};
counter=1;

for it=1:14
    %% load everything
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', [myFiles{it} '.mat']),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks', [myFiles{it} '.mat']),'consensusMask','allMasks','orMask')
    
    load(fullfile(masterFolder, 'Masks',    [myFiles{it} '.mat']), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', [myFiles{it} '.mat']), 'thisONCenter');
    
    thisImage=imread(fullfile(masterFolder, myFiles{it}));
    redImage=thisImage(:,:,1);

    
    [maskStats, maskNoCenter] = processMask(thisMask, redImage, thisONCenter);
    
    %% make blocks
    
    [blocks, ind] = getBlocks(redImage, [imageSide imageSide]);
    inMaskBlocks= getBlocksInMask(ind, thisMask.*maskNoCenter, 100);
    consensusBlocks = getBlocksInMask(ind, consensusMask, 60);
    
    %% save images
    for itBlock=1:size(inMaskBlocks, 1)
        smallBlocks(counter).image=uint8(mat2gray(blocks(:,:,inMaskBlocks(itBlock,1), inMaskBlocks(itBlock,2)))*255);
        if ismember([inMaskBlocks(itBlock,1) inMaskBlocks(itBlock,2)], consensusBlocks, 'rows')
            imwrite(uint8(mat2gray(blocks(:,:,inMaskBlocks(itBlock,1), inMaskBlocks(itBlock,2)))*255),...
                [masterFolder, 'TrainingDB/' '1/' 'Block' num2str(sprintf('%05d', counter)) '.tif']);
        else
            imwrite(uint8(mat2gray(blocks(:,:,inMaskBlocks(itBlock,1), inMaskBlocks(itBlock,2)))*255),...
                [masterFolder, 'TrainingDB/' '0/' 'Block' num2str(sprintf('%05d', counter)) '.tif']);
        end
%         else
%              imwrite(cat(3, zeros(size(thisBlock)), thisBlock, zeros(size(thisBlock))),...
%                 [masterFolder, 'TrainingDB/' 'block' num2str(it) '.jpg']);
%         end
        smallBlocks(counter).tuft=ismember([inMaskBlocks(itBlock,1) inMaskBlocks(itBlock,2)], consensusBlocks, 'rows');
        smallBlocks(counter).imageFile=myFiles{it};
        smallBlocks(counter).location=[inMaskBlocks(itBlock,1), inMaskBlocks(itBlock,2)];
        counter=counter+1;
    end
end
%%
save([masterFolder, 'TrainingDB/allBlocks.mat'], 'smallBlocks')