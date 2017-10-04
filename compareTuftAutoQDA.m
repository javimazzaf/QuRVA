function [nBetterFP, nBetterFN] = compareTuftAutoQDA

% loads local parameters
readConfig;

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

aux = load(fullfile(masterFolder,'comparisonOthers.mat'),'FPothers','FNothers','versionInfo');
FPothers = aux.FPothers;
FNothers = aux.FNothers;
versionInfo.Others = aux.versionInfo;

nPix = [];
nObj = [];

for it=1:numel(myFiles)
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask','evaluationVersInfo','trainingSetVersInfo');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'allMasks')
    allMasks = resetScale(allMasks);
    consensusMask = sum(allMasks, 3) >= consensus.reqVotes;

    nPix(it) = sum(consensusMask(:) > 0);
    
    % Automatic Method
    [consLabels, consNum]   = bwlabel(consensusMask > 0);
    [tuftsLabels, tuftsNum] = bwlabel(tuftsMask > 0);
    
    nObj(it) = consNum;
    
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

versionInfo.dayTag = datestr(now,'yyyymmdd_HH_MM');

resDir = fullfile(masterFolder,'global',[versionInfo.dayTag '_SHA_' versionInfo.sha(1:6) '_BRANCH_' versionInfo.branch]);

if ~exist(resDir,'dir'), mkdir(resDir), end

resultsText = [];

resultsText = [resultsText;{versionInfo.dayTag}];
resultsText = [resultsText;{['Comparison Version: ' versionInfo.branch         ' | ' versionInfo.sha]}];
resultsText = [resultsText;{['Evaluation Version: ' evaluationVersInfo.branch  ' | ' evaluationVersInfo.sha]}];
resultsText = [resultsText;{['Training Version  : ' trainingSetVersInfo.branch ' | ' trainingSetVersInfo.sha]}];
resultsText = [resultsText;{'----------------------------------------'}];
resultsText = [resultsText;{'Pixel statistics'}];
resultsText = [resultsText;{['scoreFP:' num2str(scoreFP)]}];
resultsText = [resultsText;{['scoreFN:' num2str(scoreFN)]}];
resultsText = [resultsText;{['Average:' num2str((scoreFP + scoreFN) / 2)]}];
resultsText = [resultsText;{'----------------------------------------'}];
resultsText = [resultsText;{'Object statistics'}];
resultsText = [resultsText;{['scoreFPo:' num2str(scoreFPo)]}];
resultsText = [resultsText;{['scoreFNo:' num2str(scoreFNo)]}];
resultsText = [resultsText;{['Average:' num2str((scoreFPo + scoreFNo)/2)]}];

disp(resultsText);

cellToTextfile(resultsText, fullfile(resDir,'results.txt'))

comparisonVersInfo = versionInfo;

save(fullfile(resDir,'performance.mat'),'FP','FN','FPo','FNo','scoreFP','scoreFN','scoreFPo','scoreFNo','evaluationVersInfo','trainingSetVersInfo','comparisonVersInfo');

% Copy Model and Training Arrays to directory
copyfile(fullfile(masterFolder, 'trainingSet.mat'),fullfile(resDir, 'trainingSet.mat'));
copyfile(fullfile(masterFolder, 'model.mat'),      fullfile(resDir, 'model.mat'));

%% Make barplots
fg=figure;
makeNiceBarFigure(FP, 'FP pixels',false)
makeFigureTight(fg)
imFP = print('-RGBImage');
imwrite(imFP,fullfile(resDir,'FP.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

fg=figure;
makeNiceBarFigure(FN, 'FN pixels',false)
makeFigureTight(fg)
imFN = print('-RGBImage');
imwrite(imFN,fullfile(resDir,'FN.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

fg=figure;
makeNiceBarFigure(FPo, 'FP objects',false)
makeFigureTight(fg)
imFPo = print('-RGBImage');
imwrite(imFPo,fullfile(resDir,'FPo.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

fg=figure;
makeNiceBarFigure(FNo, 'FN objects',false)
makeFigureTight(fg)
imFNo = print('-RGBImage');
imwrite(imFNo,fullfile(resDir,'FNo.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

imAll = cat(1, cat(2,imFP,imFN), cat(2,imFPo,imFNo));
imwrite(imAll,fullfile(resDir,'allStats.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

%% Make relative barPlots

FPrel = FP./nPix*100;
FNrel = FN./nPix*100;

fg=figure;
makeNiceBarFigure(FPrel, 'FP pixels [%]',false)
makeFigureTight(fg)
imFPp = print('-RGBImage');
imwrite(imFPp,fullfile(resDir,'FPperc.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

fg=figure;
makeNiceBarFigure(FNrel, 'FN pixels [%]',false)
makeFigureTight(fg)
imFNp = print('-RGBImage');
imwrite(imFNp,fullfile(resDir,'FNperc.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

imAll = cat(2,imFPp,imFNp);
imwrite(imAll,fullfile(resDir,'allStatsPerc.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

%% Make AllErrors bar plot grouped by method/user

allErrorRel = FNrel + FPrel;

fg=figure;
makeUserDistributionFigure(allErrorRel,'Error pixels [%]',true)
makeFigureTight(fg)
imRGB = print('-RGBImage');
imwrite(imRGB,fullfile(resDir,'errorsPerMethod.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

%% Make AllErrors bar plot only users grouped by Image
fg = figure;
makeJustUsersFigure(allErrorRel(2:7,:),'Error [%]');
makeFigureTight(fg)
aux = allErrorRel(2:7,:);
disp(['MeanUserError: ' num2str(mean(aux(:)))])
disp(['MedianUserError: ' num2str(median(aux(:)))])

imRGB = print('-RGBImage');
imwrite(imRGB,fullfile(resDir,'userErrors.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

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

