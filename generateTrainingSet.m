masterFolder = '../Anonymous/';

myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

nLim = 1000;

data = [];
res  = [];

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
    
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'allMasks');
    consensusMask = sum(allMasks, 3) >= consensus.reqVotes;
    
    trueInd = find(validMask & consensusMask);
    trueInd = trueInd(randi(numel(trueInd),[nLim,1]));
    
    falsInd = find(validMask & ~consensusMask);
    falsInd = falsInd(randi(numel(falsInd),[numel(trueInd),1]));

    imFeatures = computeImageFeatures(oImage, validMask,trueInd,falsInd);
      
    data = [data;imFeatures];
      
    res = [res;ones(size(trueInd));zeros(size(falsInd))];
      
end

save(fullfile(masterFolder, 'trainingSet.mat'),'data','res')




