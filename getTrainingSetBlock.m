readConfig

myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

data1 = [];
res1  = [];

data2 = [];
res2  = [];

% Repeatability
rng(1);

for it = 1:numel(myFiles)
    
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

    [blocks, indBlocks] = getBlocks(oImage, tufts.blockSize);
    
    % Blocks included in consensus
    trueBlocks  = getBlocksInMask(indBlocks, validMask & consensusMask, 50);
    
    % Blocks NOT included in consensus
    falseBlocks = getBlocksInMask(indBlocks, validMask & ~consensusMask, 50);

    blockFeatures = computeBlockFeatures(oImage,validMask, indBlocks,trueBlocks,falseBlocks);
      
    if it <=7
        data1 = [data1;blockFeatures];
        res1 = [res1;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
    else
        data2 = [data2;blockFeatures];
        res2 = [res2;ones([size(trueBlocks,1),1]);zeros([size(falseBlocks,1),1])];
    end
      
end

save(fullfile(masterFolder, 'trainingSet.mat'),'data1','res1','data2','res2')




