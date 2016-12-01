clear
%% Set folders
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/Anonymous/';
mkdir(masterFolder, 'Results/Global')

%% Get file names
myFiles=dir([masterFolder filesep 'Results' filesep '*.mat']);

distancesStats={[0], [0], [0], [0], [0], [0], [0], [0], [0], [0]};

%% Load results

for it=1:numel(myFiles)
    it
    load([masterFolder 'Results' filesep myFiles(it).name]);
    
    swiftMasks=collectSwift(masterFolder, myFiles(it).name, consensusMask);
        
    distanceImage(:,:,1)=tuftsMask.*bwdist(consensusMask);
    offPixelsImage(:,:,1)=abs(tuftsMask-consensusMask);

    distancesStats{1}=[distancesStats{1}; nonzeros(distanceImage(:,:,1))];
    
    for itUsers=1:size(allMasks,3)
        distanceImage(:,:,itUsers+1)=allMasks(:,:,itUsers).*bwdist(consensusMask);
        offPixelsImage(:,:,itUsers+1)=abs(allMasks(:,:,itUsers)-consensusMask);
        
        distancesStats{itUsers+1}=[distancesStats{itUsers+1}; nonzeros(distanceImage(:,:,itUsers+1))];
    end
    
    for itSwift=1:size(swiftMasks,3)
        distanceImage(:,:,itUsers+1+itSwift)=swiftMasks(:,:,itSwift).*bwdist(consensusMask);
        offPixelsImage(:,:,itUsers+1+itSwift)=abs(swiftMasks(:,:,itSwift)-consensusMask);
        
        distancesStats{itUsers+1+itSwift}=[distancesStats{itUsers+1+itSwift}; nonzeros(distanceImage(:,:,itSwift))];
    end

    
    offPixels(1:itUsers+1+itSwift, it)=reshape(sum(sum(offPixelsImage))/sum(sum(consensusMask)),...
        [size(allMasks,3)+1+size(swiftMasks,3), 1]);
    
    clear distanceImage offPixelsImage
end

save([masterFolder filesep 'Results' filesep 'Global' filesep 'Comparissons.mat'], 'offPixels', 'distancesStats')


%% Make barplots
close all
makeNiceOffPixelFigure(offPixels)

print(gcf,'-dpng',[masterFolder filesep 'Results' filesep 'Global' filesep 'Barplot.png']);


%% Make boxplots

dataToPlot=[distancesStats{1} ones(numel(distancesStats{1}),1)];

for itUsers=1:size(allMasks,3)+size(swiftMasks,3)+1
    dataToPlot=[dataToPlot; distancesStats{1+itUsers} ones(numel(distancesStats{1+itUsers}),1)*(itUsers+1)];
end


boxplot(dataToPlot(:,1), dataToPlot(:,2))

print(gcf,'-dpng',[masterFolder filesep 'Results' filesep 'Global' filesep 'Boxplot.png']);

%% Violin Plots
figure
violinplot(dataToPlot(:,1), dataToPlot(:,2))
print(gcf,'-dpng',[masterFolder filesep 'Results' filesep 'Global' filesep 'Violins.png']);
