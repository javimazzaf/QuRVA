function [FP, FN, TP, ERR] = measureTuftComparativePerformance

% loads local parameters
readConfig;

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

FP = zeros(1,numel(myFiles));
FN = zeros(1,numel(myFiles));
TP = zeros(1,numel(myFiles));
ERR = zeros(1,numel(myFiles));

for it=1:numel(myFiles)
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'allMasks')
    
    consensusMask = sum(allMasks,3) > 0.5;
    
    ourDiff = tuftsMask(:) - consensusMask(:);
    
    FP(e,it) = sum(ourDiff > 0);
    FN(e,it) = sum(ourDiff < 0);
    TP(e,it) = sum(tuftsMask(:) & consensusMask(:));
    ERR(e,it) = FP(e,it) + FN(e,it);
    
end
end