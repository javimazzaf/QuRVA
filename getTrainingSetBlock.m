masterFolder = '../Anonymous/';

myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

data = [];
res  = [];

% Repeatability
rng(1);

for it=1:numel(myFiles)
    
    disp(it)
    
    fname = myFiles{it};
    fname = fname(1:end-4);
    
    oImage = imread(fullfile(masterFolder, fname));
    oImage = oImage(:,:,1);

    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    
    [maskStats, maskNoCenter] = processMask(thisMask, oImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask');
    
    [blocks, indBlocks] = getBlocks(oImage, [25 25]);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & consensusMask, 50);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~consensusMask, 50);

    % Reduce randomly the number of false blocks to match the true blocks
%     falseBlocks = falseBlocks(randperm(size(falseBlocks,1),size(trueBlocks,1))',:);
    
    % FOR TESTING
%     msk = blocksToMask(size(oImage), ind, flaseBlocks);

    blockFeatures = computeBlockFeatures(oImage,validMask, indBlocks,trueBlocks,falseBlocks);
      
    data = [data;blockFeatures];
      
    res = [res;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
      
end

save(fullfile(masterFolder, 'trainingSet.mat'),'data','res')




