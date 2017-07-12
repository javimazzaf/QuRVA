clear

imageSide=350;

% loads local parameters
readConfig;

masterFolder='../Anonymous/';

% mkdir(masterFolder, 'ValidationVasculature')

%% Get file names
myFiles = dir(fullfile(masterFolder, '*.jpg'));
myFiles = {myFiles(:).name};
counter=1;
thisCount=table;

for it=1:14
    %% load everything
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'Masks',    [myFiles{it} '.mat']), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', [myFiles{it} '.mat']), 'thisONCenter');
    load(fullfile(masterFolder, 'VasculatureNumbers', [myFiles{it} '.mat']));
    
    
    thisImage=imread(fullfile(masterFolder, myFiles{it}));
    redImage=thisImage(:,:,1);
    
    
    [maskStats, maskNoCenter] = processMask(thisMask, redImage, thisONCenter);
    
    %% make blocks
    
    [blocks, ind] = getBlocks(redImage, [imageSide imageSide], [0,0]);
    inMaskBlocks= getBlocksInMask(ind, thisMask.*maskNoCenter, 100, [0,0]);
    
    [branchBlocks, brInd] = getBlocks(brchPts, [imageSide imageSide], [0,0]);
    inMaskBranchBlocks= getBlocksInMask(brInd, thisMask.*maskNoCenter, 100, [0,0]);
    for itBlock=1:size(inMaskBlocks, 1)
        thisCount(counter,:)={it, itBlock,sum(sum(logical(branchBlocks(:,:,inMaskBranchBlocks(itBlock,1), inMaskBranchBlocks(itBlock,2)))))};
        theseLocations{counter}=find((logical(branchBlocks(:,:,inMaskBranchBlocks(itBlock,1), inMaskBranchBlocks(itBlock,2))))==1);
        counter=counter+1;
        save([masterFolder, 'ValidationVasculature/automaticRefined.mat'], 'thisCount');
    end
end

