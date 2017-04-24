clear

% loads local parameters
readConfig;

mkdir(masterFolder, 'Global')

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

distancesStats = num2cell(zeros(1,13));

%% Load results

for it=1:numel(myFiles)
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask','allMasks')
    
    swiftMasks=collectSwift(masterFolder, myFiles{it}, consensusMask);
        
    distanceImage(:,:,1)=tuftsMask.*bwdist(consensusMask);
    falsePositivePixelsImage(:,:,1)=uint8((tuftsMask-consensusMask)>0);
    falseNegativePixelsImage(:,:,1)=uint8((tuftsMask-consensusMask)<0);

    distancesStats{1}=[distancesStats{1}; nonzeros(distanceImage(:,:,1))];
    
   
    for itUsers=1:size(allMasks,3)
        distanceImage(:,:,itUsers+1)=allMasks(:,:,itUsers).*bwdist(consensusMask);
        falsePositivePixelsImage(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-consensusMask)>0);
        falseNegativePixelsImage(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-consensusMask)<0);
        
        distancesStats{itUsers+1}=[distancesStats{itUsers+1}; nonzeros(distanceImage(:,:,itUsers+1))];
        
    end
    
    for itSwift=1:size(swiftMasks,3)
        distanceImage(:,:,itUsers+1+itSwift)=swiftMasks(:,:,itSwift).*bwdist(consensusMask);
        
        %% Check if I got zeros because the user did not analyze this image
        if max(max(swiftMasks(:,:,itSwift)))==0
            falsePositivePixelsImage(:,:,itUsers+1+itSwift)=NaN(size(consensusMask));
            falseNegativePixelsImage(:,:,itUsers+1+itSwift)=NaN(size(consensusMask));
        else
            falsePositivePixelsImage(:,:,itUsers+1+itSwift)=uint8((swiftMasks(:,:,itSwift)-consensusMask)>0);
            falseNegativePixelsImage(:,:,itUsers+1+itSwift)=uint8((swiftMasks(:,:,itSwift)-consensusMask)<0);
        end
        
        distancesStats{itUsers+1+itSwift}=[distancesStats{itUsers+1+itSwift}; nonzeros(distanceImage(:,:,itUsers+1+itSwift))];
%                 distancesStats{itUsers+1}=[distancesStats{itUsers+1}; nonzeros(distanceImage(:,:,itUsers+1))];
       
    end

    falsePositivePixelsImage(1:itUsers+1+itSwift, it)=reshape(sum(sum(falsePositivePixelsImage))/sum(sum(consensusMask)),...
        [size(allMasks,3)+1+size(swiftMasks,3), 1]);
    falseNegativePixelsImage(1:itUsers+1+itSwift, it)=reshape(sum(sum(falseNegativePixelsImage))/sum(sum(consensusMask)),...
        [size(allMasks,3)+1+size(swiftMasks,3), 1]);
    
    falsePositivePixels(1:itUsers+1+itSwift, it)=reshape(sum(sum(falsePositivePixelsImage)),...
        [size(allMasks,3)+1+size(swiftMasks,3), 1]);
    falseNegativePixels(1:itUsers+1+itSwift, it)=reshape(sum(sum(falseNegativePixelsImage)),...
        [size(allMasks,3)+1+size(swiftMasks,3), 1]);
    
    clear distanceImage falsePositivePixelsImage falseNegativePixelsImage
end

save([masterFolder filesep 'Global' filesep 'Comparisons.mat'], 'falsePositivePixels', 'falseNegativePixels', 'distancesStats')


%% Make barplots
load([masterFolder filesep 'Global' filesep 'Comparisons.mat'], 'falsePositivePixels', 'falseNegativePixels', 'distancesStats')
figure;
makeNiceOffPixelFigure(falsePositivePixels)
% ylim([0 3.5E5])
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFPpixels.png'));

figure;
makeNiceOffPixelFigure(falseNegativePixels)
% ylim([0 3.5E5])
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFNpixels.png'));
%% Relative

% figure;
% makeNiceOffPixelRelativeFigure(falsePositivePixels)
% print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFPpixelsRelative.png'));
% 
% figure;
% makeNiceOffPixelRelativeFigure(falseNegativePixels)
% print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFNpixelsRelative.png'));

%% Make boxplots
figure

dataToPlot=[distancesStats{1} ones(numel(distancesStats{1}),1)];

for itUsers=1:size(allMasks,3)+size(swiftMasks,3)
    dataToPlot=[dataToPlot; distancesStats{1+itUsers} ones(numel(distancesStats{1+itUsers}),1)*(itUsers+1)];
end


boxplot(dataToPlot(:,1), dataToPlot(:,2))

print(gcf,'-dpng',fullfile(masterFolder,'Global','Boxplot.png'));

% %% Violin Plots
% figure
% violinplot(dataToPlot(:,1), dataToPlot(:,2))
% print(gcf,'-dpng',[masterFolder filesep 'Global' filesep 'Violins.png']);
