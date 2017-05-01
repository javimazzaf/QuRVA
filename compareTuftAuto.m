function [nBetterFP, nBetterFN] = compareTuftAuto

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

%%
label = 13;
% nWorseFP = countWorseThanFMA(FP,label);
% nWorseFN = countWorseThanFMA(FN,label);
% 
% nWorseFPo = countWorseThanFMA(FPo,label);
% nWorseFNo = countWorseThanFMA(FNo,label);

% disp('----------------------------------------')
% disp(['nWorseFP:' num2str(nWorseFP)])
% disp(['nWorseFN:' num2str(nWorseFN)])
% disp(['Total   :' num2str(nWorseFP + nWorseFN)])
% disp('----------------------------------------')
% disp(['nWorseFPo:' num2str(nWorseFPo)])
% disp(['nWorseFNo:' num2str(nWorseFNo)])
% disp(['Total   :' num2str(nWorseFPo + nWorseFNo)])

scoreFP  = getScore(FP, label);
scoreFN  = getScore(FN, label);
scoreFPo = getScore(FPo, label);
scoreFNo = getScore(FNo, label);

disp('----------------------------------------')
% disp(['scoreFP:' num2str(scoreFP)])
% disp(['scoreFN:' num2str(scoreFN)])
disp(['Average:' num2str((scoreFP + scoreFN) / 2)])
% disp('----------------------------------------')
% disp(['scoreFPo:' num2str(scoreFPo)])
% disp(['scoreFNo:' num2str(scoreFNo)])
% disp(['Average :' num2str((scoreFPo + scoreFNo)/2)])

%% Make barplots
figure;
makeNiceBarFigure(FP, 'FP pixels')

figure;
makeNiceBarFigure(FN, 'FN pixels')

figure;
makeNiceBarFigure(FPo, 'FP pixels')

figure;
makeNiceBarFigure(FNo, 'FN pixels')

end

function count = countWorseThanFMA(errors, label)

nMethods = size(errors,1);

[~, ix] = sort(errors);
[rate, ~] = find(ix == label);

count = sum(nMethods - rate);

end

function score = getScore(errors, label)

[~, ix] = sort(errors);
[rate, ~] = find(ix == label);

score = mean(rate);

end

