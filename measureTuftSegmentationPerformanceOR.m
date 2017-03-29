function [FP, FN, TP, ERR] = measureTuftSegmentationPerformanceOR

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
    
    differences = tuftsMask(:) - consensusMask(:);

    FP(it) = sum(differences > 0);
    FN(it) = sum(differences < 0);
    TP(it) = sum(tuftsMask(:) & consensusMask(:));
    
    ERR(it) = FP(it) + FN(it);
end