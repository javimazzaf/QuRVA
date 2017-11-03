clear 
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/IOVS/';

pWeeks=2:7;

mutants={'WT' 'Lyz' 'NrpLyz'};
for itMutant=1:3
    for it=1:numel(pWeeks)

        %% Get file names
        myFiles=dir([masterFolder mutants{itMutant} filesep 'P' num2str(pWeeks(it)) filesep '*.jpg']);

        if numel(myFiles)==0
            myFiles=dir([masterFolder mutants{itMutant} filesep 'P' num2str(pWeeks(it)) filesep '*.tif']);
        end

        for itFile=1:numel(myFiles)
            load([masterFolder mutants{itMutant} filesep 'P' num2str(pWeeks(it)) filesep 'VasculatureNumbers' filesep myFiles(itFile).name '.mat'])
            load([masterFolder mutants{itMutant} filesep 'P' num2str(pWeeks(it)) filesep 'Masks' filesep myFiles(itFile).name '.mat'])
            skelLength{it, itMutant, itFile}=sum(sum(vesselSkelMask));
            totalBrunching{it, itMutant, itFile}=sum(sum(brchPts));
            totalEndPoints{it, itMutant, itFile}=sum(sum(endPts));
            %skelRatio{it, itMutant, itFile}=double(skelLength)/double(sum(sum(thisMask)));
            %brchDensity{it, itMutant, itFile}=double(totalBrunching)/double(sum(sum(thisMask)));
            %endPtDensity{it, itMutant, itFile}=double(totalEndPoints)/double(sum(sum(thisMask)));
        end

        pSkelMean(it, itMutant)=mean(cell2mat(skelLength(it, itMutant, :)));
        %pSkelSTD(it, itMutant)=std(cell2mat(skelRatio(it, itMutant, :)));
        
        meanBrunching(it, itMutant)=mean(cell2mat(totalBrunching(it, itMutant, :)));
        meanEndPts(it, itMutant)=mean(cell2mat(totalEndPoints(it, itMutant, :)));

    end
end

%% Make figure
figure1 = figure;
axes1 = axes('Parent',figure1);
bar1 = bar([2:7],pSkelMean,'Parent',axes1);
set(bar1(1),'FaceColor', [0.850980401039124 0.325490206480026 0.0980392172932625]);
set(bar1(2),'FaceColor', [0.466666668653488 0.674509823322296 0.18823529779911]);
set(bar1(3),'FaceColor', [0 0.447058826684952 0.74117648601532]);

set(bar1(1),'DisplayName','WT');
set(bar1(2),'DisplayName','Lyz');
set(bar1(3),'DisplayName','NrpLyz^{fl/fl}');
set(axes1,'XTick',[2 3 4 5 6 7], 'XTickLabel',{'P2','P3','P4','P5','P6','P7'});
ylabel('Skeleton Length [pixels]');
set(axes1,'FontSize',16);
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.203879598662207 0.783653827939326 0.107023411371237 0.0913461538461539],'EdgeColor',[1 1 1]);
print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/SkeletonLength.png');

%%
figure2 = figure;
axes2 = axes('Parent',figure2);
bar2 = bar([2:7],meanBrunching,'Parent',axes2);
set(bar2(1),'FaceColor', [0.850980401039124 0.325490206480026 0.0980392172932625]);
set(bar2(2),'FaceColor', [0.466666668653488 0.674509823322296 0.18823529779911]);
set(bar2(3),'FaceColor', [0 0.447058826684952 0.74117648601532]);

set(bar2(1),'DisplayName','WT');
set(bar2(2),'DisplayName','Lyz');
set(bar2(3),'DisplayName','NrpLyz^{fl/fl}');
set(axes2,'XTick',[2 3 4 5 6 7], 'XTickLabel',{'P2','P3','P4','P5','P6','P7'});
ylabel('Number of branch points');
set(axes2,'YTick',[0 5000 10000]);
axes2.YTickLabelRotation=90;
set(axes2,'FontSize',16);

print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/skeletonBrunchPoints.png');
%%
figure3 = figure;
axes3 = axes('Parent',figure3);
bar3 = bar([2:7],meanEndPts,'Parent',axes3);
set(bar3(1),'FaceColor', [0.850980401039124 0.325490206480026 0.0980392172932625]);
set(bar3(2),'FaceColor', [0.466666668653488 0.674509823322296 0.18823529779911]);
set(bar3(3),'FaceColor', [0 0.447058826684952 0.74117648601532]);

set(bar3(1),'DisplayName','WT');
set(bar3(2),'DisplayName','Lyz');
set(bar3(3),'DisplayName','NrpLyz^{fl/fl}');
set(axes3,'XTick',[2 3 4 5 6 7], 'XTickLabel',{'P2','P3','P4','P5','P6','P7'});
set(axes3,'YTick',[0 1000 2000 3000]);
ylabel('Number of endpoints');
axes3.YTickLabelRotation=90;
set(axes3,'FontSize',16);
print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/skeletonEndPoints.png');

%% Compare to manual
vascArea=[13 13 13;20 20 22; 39 38 25; 45 50 49; 66 62 60; 78 76 75];
filopodiaNumber=[51 52 52; 58 61 63; 60 57 64; 58 53 57; 62 70 68; 48 43 46] ;
manualBranches=[75 75 90; 82 120 90; 110 102 95; 130 110 115; 115 120 140; 110 105 120];

%
figure4 = figure;
axes4 = axes('Parent',figure4);
hold(axes4,'on');
plot(pSkelMean(:,1), vascArea(:,1), 'MarkerFaceColor', [0.850980401039124 0.325490206480026 0.0980392172932625],'Marker','o','LineStyle','none', 'Color',[0.850980401039124 0.325490206480026 0.0980392172932625], 'MarkerSize',10, 'DisplayName','WT');
plot(pSkelMean(:,2), vascArea(:,2), 'MarkerFaceColor', [0.466666668653488 0.674509823322296 0.18823529779911], 'Marker','o','LineStyle','none', 'Color', [0.466666668653488 0.674509823322296 0.18823529779911], 'MarkerSize',10, 'DisplayName','LysM-Cre');
plot(pSkelMean(:,3), vascArea(:,3), 'MarkerFaceColor', [0 0.447058826684952 0.74117648601532],'Marker','o','LineStyle','none', 'Color',[0 0.447058826684952 0.74117648601532], 'MarkerSize',10, 'DisplayName','LysM-Cre/Nrp1^{fl/fl}');
set(axes4,'FontSize',14);
xlabel('QuRVA Vascular Length');
ylabel('Manual Vascular Area [%]');
set(axes4,'FontSize',16);
legend1 = legend(axes4,'show');
set(legend1,'Position',[0.223879598662207 0.783653827939326 0.107023411371237 0.0913461538461539], 'EdgeColor',[1 1 1]);
print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/VasculatureAreaCorrelation.png');

%%
figure5 = figure;
axes5 = axes('Parent',figure5);
hold(axes5,'on');
plot(meanBrunching(:,1)./pSkelMean(:,1), manualBranches(:,1), 'MarkerFaceColor', [0.850980401039124 0.325490206480026 0.0980392172932625],'Marker','o','LineStyle','none', 'Color',[0.850980401039124 0.325490206480026 0.0980392172932625], 'MarkerSize',10, 'DisplayName','WT');
plot(meanBrunching(:,2)./pSkelMean(:,2), manualBranches(:,2), 'MarkerFaceColor', [0.466666668653488 0.674509823322296 0.18823529779911], 'Marker','o','LineStyle','none', 'Color', [0.466666668653488 0.674509823322296 0.18823529779911], 'MarkerSize',10, 'DisplayName','LysM-Cre');
plot(meanBrunching(:,3)./pSkelMean(:,3), manualBranches(:,3), 'MarkerFaceColor', [0 0.447058826684952 0.74117648601532],'Marker','o','LineStyle','none', 'Color',[0 0.447058826684952 0.74117648601532], 'MarkerSize',10, 'DisplayName','LysM-Cre/Nrp1^{fl/fl}');
set(axes5,'FontSize',14);
xlabel('QuRVA Number of branch points ');
ylabel('Number of branch points (manual)');
set(axes5,'FontSize',16);
print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/branchPointCorrelation.png');


%%
figure6 = figure;
axes6 = axes('Parent',figure6);
hold(axes6,'on');
plot(meanEndPts(:,1)*100, filopodiaNumber(:,1), 'MarkerFaceColor', [0.850980401039124 0.325490206480026 0.0980392172932625],'Marker','o','LineStyle','none', 'Color',[0.850980401039124 0.325490206480026 0.0980392172932625], 'MarkerSize',10, 'DisplayName','WT');
plot(meanEndPts(:,2)*100, filopodiaNumber(:,2), 'MarkerFaceColor', [0.466666668653488 0.674509823322296 0.18823529779911], 'Marker','o','LineStyle','none', 'Color', [0.466666668653488 0.674509823322296 0.18823529779911], 'MarkerSize',10, 'DisplayName','LysM-Cre');
plot(meanEndPts(:,3)*100, filopodiaNumber(:,3), 'MarkerFaceColor', [0 0.447058826684952 0.74117648601532],'Marker','o','LineStyle','none', 'Color',[0 0.447058826684952 0.74117648601532], 'MarkerSize',10, 'DisplayName','LysM-Cre/Nrp1^{fl/fl}');
set(axes6,'FontSize',14);
xlabel('QuRVA Number of endpoints');
ylabel('Filopodia number (manual)');
set(axes6,'FontSize',16);
print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/FilopodiaCorrelation.png');



%% Correlations
pArea=corrcoef(pSkelMean, vascArea)
pArea=corrcoef(meanBrunching, manualBranches)
pArea=corrcoef(meanEndPts, filopodiaNumber)

%% Nice idea of Plot
load discrim 
h = gscatter(ratings(:,1),ratings(:,2),group,'br','xo'); 
hold on 
font = 'Calibri';
m    = 'P1'; 
x = get(h(2),'Xdata');
y = get(h(2),'Ydata');
text(x,y,m,'fontname',font,'FontSize', 20, 'HorizontalAl','center','color','r')
delete(h(2))
hold off