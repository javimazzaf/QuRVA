function [nBetterFP, nBetterFN] = compareTuftAutoRF

% loads local parameters
readConfig;

%Ensures everything is commited before starting test.
[branch, sha] = getGitInfo;

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbersRF','*.mat'));
myFiles = {myFiles(:).name};

load(fullfile(masterFolder,'comparisonOthers.mat'),'FPothers','FNothers','FPoOthers','FNoOthers')

%% Load results

for it=1:numel(myFiles)
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbersRF', myFiles{it}),'tuftsMask');
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

%% Scores
label = 1;

scoreFP  = getScore(FP, label);
scoreFN  = getScore(FN, label);
scoreFPo = getScore(FPo, label);
scoreFNo = getScore(FNo, label);

dayTag = datestr(now,'yyyymmdd_HH_MM');

resDir = fullfile(masterFolder,'global',[dayTag '_SHA_' sha(1:6) '_BRANCH_' branch]);

if ~exist(resDir,'dir'), mkdir(resDir), end

resultsText = [];

resultsText = [resultsText;{dayTag}];
resultsText = [resultsText;{['git branch: ' branch ' | sha ' sha]}];
resultsText = [resultsText;{'Pixel statistics'}];
resultsText = [resultsText;{['scoreFP:' num2str(scoreFP)]}];
resultsText = [resultsText;{['scoreFN:' num2str(scoreFN)]}];
resultsText = [resultsText;{['Average:' num2str((scoreFP + scoreFN) / 2)]}];
resultsText = [resultsText;{'----------------------------------------'}];
resultsText = [resultsText;{'Object statistics'}];
resultsText = [resultsText;{['scoreFPo:' num2str(scoreFPo)]}];
resultsText = [resultsText;{['scoreFNo:' num2str(scoreFNo)]}];
resultsText = [resultsText;{['Average:' num2str((scoreFPo + scoreFNo)/2)]}];

cellToTextfile(resultsText, fullfile(resDir,'results.txt'))

save(fullfile(resDir,'performance.mat'),'FP','FN','FPo','FNo','scoreFP','scoreFN','scoreFPo','scoreFNo','branch','sha','dayTag');

%% Make barplots
fg=figure;
makeNiceBarFigure(FP, 'FP pixels',false)
makeFigureTight(fg)
print(fg,fullfile(resDir,'FP.png'),'-dpng')
imFP = print('-RGBImage');

fg=figure;
makeNiceBarFigure(FN, 'FN pixels',false)
makeFigureTight(fg)
print(fg,fullfile(resDir,'FN.png'),'-dpng')
imFN = print('-RGBImage');

fg=figure;
makeNiceBarFigure(FPo, 'FP objects',false)
makeFigureTight(fg)
print(fg,fullfile(resDir,'FPo.png'),'-dpng')
imFPo = print('-RGBImage');

fg=figure;
makeNiceBarFigure(FNo, 'FN objects',false)
makeFigureTight(fg)
print(fg,fullfile(resDir,'FNo.png'),'-dpng')
imFNo = print('-RGBImage');

imAll = cat(1, cat(2,imFP,imFN), cat(2,imFPo,imFNo));
imwrite(imAll,fullfile(resDir,'allStats.png'),'png')

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

