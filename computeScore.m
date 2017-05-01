function [scorePix, scoreObj, evScorePix, evScoreObj] = computeScore

% loads local parameters
readConfig;

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

load(fullfile(masterFolder,'comparisonOthers.mat'),'FPothers','FNothers','FPoOthers','FNoOthers')

%% Load results

for it=1:numel(myFiles)
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask')

    % Automatic Method
    [consLabels, consNum]   = bwlabel(consensusMask > 0);
    [tuftsLabels, tuftsNum] = bwlabel(tuftsMask > 0);
    
    FNo(it) = numel(setdiff(1:consNum, unique(consLabels(:) .* tuftsMask(:))));
    FPo(it) = numel(setdiff(1:tuftsNum, unique(tuftsLabels(:) .* consensusMask(:))));
    
    FP(it) = sum(tuftsMask(:) > consensusMask(:));
    FN(it) = sum(tuftsMask(:) < consensusMask(:));
    
end

FP = [ FP ; FPothers];
FN = [ FN ; FNothers];

FPo = [ FPo ; FPoOthers];
FNo = [ FNo ; FNoOthers];

label = 1;

[scoresFP,othersFP]  = getScores(FP, label);
[scoresFN,othersFN]  = getScores(FN, label);
[scoresFPo,othersFPo] = getScores(FPo, label);
[scoresFNo,othersFNo] = getScores(FNo, label);

scorePix = mean([scoresFP(:)  ; scoresFN(:)]);
scoreObj = mean([scoresFPo(:) ; scoresFNo(:)]);

evScorePix = mean([othersFP';othersFN'])';
evScoreObj = mean([othersFPo';othersFNo'])';

end

function [scores, others] = getScores(errors, label)

[~, ix] = sort(errors);

others = NaN(size(errors));

for l = 1:13
    [others(l,:), ~] = find(ix == l);
end

scores = others(label,:);

others = others(setdiff(1:13,label),:);

end

