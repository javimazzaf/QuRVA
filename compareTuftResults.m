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
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask','allMasks','orMask')
    thisMask     = resetScale(thisMask);
    
    areaVotos(it) = sum(consensusMask(:));
    
    % Modify evaluation by replacing the consensus by the orMask.
%     consensusMask = orMask;
    
    swiftMasks=collectSwift(masterFolder, myFiles{it}, consensusMask);
        
    distanceImage(:,:,1)=tuftsMask.*bwdist(consensusMask);
    falsePositivePixelsImage(:,:,1)=uint8((tuftsMask-consensusMask)>0);
    falseNegativePixelsImage(:,:,1)=uint8((tuftsMask-consensusMask)<0);

    falsePositivePixelsImageOr(:,:,1)=uint8((tuftsMask-orMask)>0);
    falseNegativePixelsImageOr(:,:,1)=uint8((tuftsMask-orMask)<0);
    
    distancesStats{1}=[distancesStats{1}; nonzeros(distanceImage(:,:,1))];
    
    nObjects(1,it) = max(max(bwlabel(tuftsMask)));
    
    areas(1,it) = sum(tuftsMask(:));
    
    areaOr(it) = sum(orMask(:));
   
    for itUsers=1:size(allMasks,3)
        distanceImage(:,:,itUsers+1)=allMasks(:,:,itUsers).*bwdist(consensusMask);
        falsePositivePixelsImage(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-consensusMask)>0);
        falseNegativePixelsImage(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-consensusMask)<0);
        
        falsePositivePixelsImageOr(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-orMask)>0);
        falseNegativePixelsImageOr(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-orMask)<0);
        
        distancesStats{itUsers+1}=[distancesStats{itUsers+1}; nonzeros(distanceImage(:,:,itUsers+1))];
        
        nObjects(itUsers+1,it) = max(max(bwlabel(allMasks(:,:,itUsers))));
        
        areas(itUsers+1,it) = sum(sum(allMasks(:,:,itUsers)));
        
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
            
            falsePositivePixelsImageOr(:,:,itUsers+1+itSwift)=uint8((swiftMasks(:,:,itSwift)-orMask)>0);
            falseNegativePixelsImageOr(:,:,itUsers+1+itSwift)=uint8((swiftMasks(:,:,itSwift)-orMask)<0);
            
        end
        
        distancesStats{itUsers+1+itSwift}=[distancesStats{itUsers+1+itSwift}; nonzeros(distanceImage(:,:,itUsers+1+itSwift))];
%                 distancesStats{itUsers+1}=[distancesStats{itUsers+1}; nonzeros(distanceImage(:,:,itUsers+1))];

        nObjects(itUsers+1+itSwift,it) = max(max(bwlabel(swiftMasks(:,:,itSwift))));
        
        areas(itUsers+1+itSwift,it) = sum(sum(swiftMasks(:,:,itSwift)));

    end
    
    areasRelativasVotos(:,it) = areas(:,it) / areaVotos(it);
    areasRelativasOR(:,it)    = areas(:,it) / areaOr(it);
    
    falsePositivePixels(:, it) = squeeze(sum(sum(falsePositivePixelsImage,1),2));
    falseNegativePixels(:, it) = squeeze(sum(sum(falseNegativePixelsImage,1),2));
    
    falsePositivePixelsOr(:, it) = squeeze(sum(sum(falsePositivePixelsImageOr,1),2));
    falseNegativePixelsOr(:, it) = squeeze(sum(sum(falseNegativePixelsImageOr,1),2));
    
    falsePositiveRelative(:, it) = falsePositivePixels(:, it) / sum(consensusMask(:));
    falseNegativeRelative(:, it) = falseNegativePixels(:, it) / sum(consensusMask(:));
    
    falsePositiveRelativeOr(:, it) = falsePositivePixelsOr(:, it) / sum(orMask(:));
    falseNegativeRelativeOr(:, it) = falseNegativePixelsOr(:, it) / sum(orMask(:));
    
    clear distanceImage falsePositivePixelsImage falseNegativePixelsImage falsePositivePixelsImageOr falseNegativePixelsImageOr
end

save([masterFolder filesep 'Global' filesep 'Comparissons.mat'], 'falsePositivePixels', 'falseNegativePixels', 'distancesStats')


%% Make barplots Votos
close all
figure;
makeNiceOffPixelFigure(falsePositivePixels)
% ylim([0 3.5E5])
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFPpixelsVotos.png'));

figure;
makeNiceOffPixelFigure(falseNegativePixels)
% ylim([0 3.5E5])
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFNpixelsVotos.png'));

%% Make TODOS los errores
allErrors = falsePositivePixels + falseNegativePixels;

for it=1:numel(myFiles)
    allErrors(:,it) = allErrors(:,it) / areaVotos(it);
end

figure;
makeNiceOffPixelFigure(allErrors); title('All Errors relive to Votos')

print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotErrorsVotos.png'));
%% Relative Votos

figure;
makeNiceOffPixelRelativeFigure(falsePositiveRelative)
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFPpixelsRelativeVotos.png'));

figure;
makeNiceOffPixelRelativeFigure(falseNegativeRelative)
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFNpixelsRelativeVotos.png'));

%% Make barplots Todos
close all
figure;
makeNiceOffPixelFigure(falsePositivePixelsOr)
% ylim([0 3.5E5])
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFPpixelsTodos.png'));

figure;
makeNiceOffPixelFigure(falseNegativePixelsOr)
% ylim([0 3.5E5])
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFNpixelsTodos.png'));
%% Relative Todos

figure;
makeNiceOffPixelRelativeFigure(falsePositiveRelativeOr)
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFPpixelsRelativeTodos.png'));

figure;
makeNiceOffPixelRelativeFigure(falseNegativeRelativeOr)
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFNpixelsRelativeTodos.png'));

%% Make Other plots

figure;
makeNiceOffPixelFigure(nObjects);title('nObjects');
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotnObjects.png'));

figure;
makeNiceOffPixelFigure(areas);title('areas');
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotAreas.png'));

figure;
makeNiceOffPixelFigure(areasRelativasVotos);title('areas relativas Votos');
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotAreasRelativasVotos.png'));

figure;
makeNiceOffPixelFigure(areasRelativasOR);title('areas relativas Todos');
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotAreasRelativasTodos.png'));


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
