% cargar caracterisiticas y dibujas cada una versus consensus o no consensus.

readConfig

resDir = '/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/exploratory/';
if ~exist(resDir,'dir'), mkdir(resDir), end

%Ensures everything is commited before starting test.
% [figVersionInfo.branch, figVersionInfo.sha] = getGitInfo;

load(fullfile(masterFolder, 'trainingSet.mat'),'data1','res1','data2','res2','versionInfo')
featuresInfo = versionInfo;

data = [data1;data2];
res  = [res1;res2];

%%
nBins = 15;

xLabels={'I_{loc}', 'I_{g}', 'I_{loG}', 'LBP_{0}', 'LBP_{1}','LBP_{2}', ...
    'LBP_{3}', 'LBP_{4}', 'LBP_{5}', 'LBP_{6}', 'LBP_{7}', 'LBP_{8}', 'LBP_{9}'};

for ft = 1:13
    fg=figure
    violins = violinplot(data(:,ft), res,'Width',0.2,'ShowData',false);
    violins(1).ViolinColor = [1 0 0];
    violins(1).ViolinAlpha = 0.8
    violins(2).ViolinAlpha = 0.8
    violins(2).ViolinColor = [1 0 1];
    xlim([0.2 2.8])
    set(gca,'YTick',[],'XTick',[], 'FontSize',40)
    annotation(fg,'textbox',...
    [0.72 0.75 1 0.15],...
    'String',xLabels{ft},'FontSize',60, 'LineStyle','none','FontName','Times New Roman',...
    'FitBoxToText', 'on');

    print(fg,fullfile(resDir, ['violinsFt' num2str(ft) '.png']),'-dpng')
    
    close all
    
end

% makeFigureTight(fg)

% save(fullfile(resDir,'codeVersion.mat'),'figVersionInfo','featuresInfo')

% copyfile(fullfile(masterFolder, 'trainingSet.mat'),fullfile(resDir, 'trainingSet.mat'))

print(fg,fullfile(resDir, 'violins.png'),'-dpng')