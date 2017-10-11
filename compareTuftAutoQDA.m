function compareTuftAutoQDA

codeDirectory = './PaperCode/';
addpath(codeDirectory);
toDelete = onCleanup(@() rmpath(codeDirectory));

% loads local parameters
readConfig;

resDir = fullfile(masterFolder, 'Global');

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

for it=[1:3,5:6,9:12,14] %1:numel(myFiles)
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'allMasks')
    allMasks = resetScale(allMasks);
    consensusMask = sum(allMasks, 3) >= consensus.reqVotes;   

    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    [thisMask,scaleFactor] = resetScale(thisMask);
    thisONCenter = thisONCenter/scaleFactor;
    
    [maskStats, maskNoCenter] = processMask(thisMask, consensusMask, thisONCenter);
    
    validMask = maskNoCenter & thisMask;

    %**** ERROR : Calcular los pixeles del consenso, solo en thisMask !!!
    nPix(it) = sum(consensusMask(validMask(:)) > 0);

    FP(it) = sum(tuftsMask(validMask(:)) > consensusMask(validMask(:)));
    FN(it) = sum(tuftsMask(validMask(:)) < consensusMask(validMask(:)));
    
end

FP = [ FP ; FPothers];
FN = [ FN ; FNothers];

save(fullfile(masterFolder,'comparisonAll.mat'),'FP','FN','nPix','versionInfo');

%% 
readConfig;
load(fullfile(masterFolder,'comparisonAll.mat'),'FP','FN','nPix','versionInfo');

FPrel = FP./nPix*100;
FNrel = FN./nPix*100;

allErrorRel = FNrel + FPrel;

frmt = '%03.1f';
disp( 'Error QuRVA |  FN[%]  |  FP[%]  |  TOTAL[%] ')
disp(['            |' num2str(nanmedian(FNrel(1,:)),frmt)...
                '     |' num2str(nanmedian(FPrel(1,:)),frmt)...
                '     |' num2str(nanmedian(allErrorRel(1,:)),frmt)])

% %% Make barplots
% fg=figure;
% makeNiceBarFigure(FP, 'FP pixels',false)
% % makeFigureTight(fg)
% imFP = print('-RGBImage');
% imwrite(imFP,fullfile(resDir,'FP.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])
% 
% fg=figure;
% makeNiceBarFigure(FN, 'FN pixels',false)
% % makeFigureTight(fg)
% imFN = print('-RGBImage');
% imwrite(imFN,fullfile(resDir,'FN.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])
% 
% imAll = cat(1, cat(2,imFP,imFN));
% imwrite(imAll,fullfile(resDir,'allStats.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

%% Make relative barPlots

fg=figure;
makeNiceBarFigure(FPrel, 'FP pixels [%]',false)
% makeFigureTight(fg)
imFPp = print('-RGBImage');
imwrite(imFPp,fullfile(resDir,'FPperc.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

fg=figure;
makeNiceBarFigure(FNrel, 'FN pixels [%]',false)
% makeFigureTight(fg)
imFNp = print('-RGBImage');
imwrite(imFNp,fullfile(resDir,'FNperc.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

imAll = cat(2,imFPp,imFNp);
imwrite(imAll,fullfile(resDir,'allStatsPerc.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

%% Make AllErrors bar plot grouped by method/user

fg=figure;
makeUserDistributionFigure(allErrorRel,'Error pixels [%]',true)
ylim([0 prctile(allErrorRel(:),97.4)])
% makeFigureTight(fg)
imRGB = print('-RGBImage');
imwrite(imRGB,fullfile(resDir,'errorsPerMethod.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

%% Make AllErrors bar plot only users grouped by Image
fg = figure;
makeJustUsersFigure(allErrorRel(2:7,:),'Error [%]');
% makeFigureTight(fg)
aux = allErrorRel(2:7,:);
disp(['MeanUserError: ' num2str(mean(aux(:)))])
disp(['MedianUserError: ' num2str(median(aux(:)))])

imRGB = print('-RGBImage');
imwrite(imRGB,fullfile(resDir,'userErrors.png'),'png','Comment',['Comparison Version: ' versionInfo.branch ' | ' versionInfo.sha])

end



