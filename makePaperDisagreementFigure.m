clear

% loads local parameters
readConfig;
%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

distancesStats = num2cell(zeros(1,13));

for it=1:14
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask','allMasks','orMask')
    consensusMask = sum(allMasks, 3)>ceil(size(allMasks, 3)/2);
    areaVotos(it) = sum(consensusMask(:));
    
    % Modify evaluation by replacing the consensus by the orMask.
%     consensusMask = orMask;
    
    swiftMasks=collectSwift(masterFolder, myFiles{it}, consensusMask);
        
    
    falsePositivePixelsImage(:,:,1)=uint8((tuftsMask-consensusMask)>0);
    falseNegativePixelsImage(:,:,1)=uint8((tuftsMask-consensusMask)<0);

    falsePositivePixelsImageOr(:,:,1)=uint8((tuftsMask-orMask)>0);
    falseNegativePixelsImageOr(:,:,1)=uint8((tuftsMask-orMask)<0);
    
        
    nObjects(1,it) = max(max(bwlabel(tuftsMask)));
    
    areas(1,it) = sum(tuftsMask(:));
    
    areaOr(it) = sum(orMask(:));
   
    for itUsers=1:size(allMasks,3)
        distanceImage(:,:,itUsers+1)=allMasks(:,:,itUsers).*bwdist(consensusMask);
        falsePositivePixelsImage(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-consensusMask)>0);
        falseNegativePixelsImage(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-consensusMask)<0);
        
        falsePositivePixelsImageOr(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-orMask)>0);
        falseNegativePixelsImageOr(:,:,itUsers+1)=uint8((allMasks(:,:,itUsers)-orMask)<0);
        
        
        
        nObjects(itUsers+1,it) = max(max(bwlabel(allMasks(:,:,itUsers))));
        
        areas(itUsers+1,it) = sum(sum(allMasks(:,:,itUsers)));
        
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

%% Make TODOS los errores
allErrors = falsePositivePixels + falseNegativePixels;

for it=1:14
    allErrors(:,it) = allErrors(:,it) / areaVotos(it);
end

figure;
axes1 = axes('Parent',gcf);
bar1 = bar(allErrors(2:7,:)'*100,'Parent',axes1);
set(bar1(1),'FaceColor',[1 0 0], 'DisplayName','FMA');

for it=1:6
    set(bar1(it),'FaceColor',[0 it*1/7+1/7 0], 'DisplayName',['User ' num2str(it)]);
end

for it=1:14
    xEtiquetas{it}=['Image ' num2str(it)];
end

set(axes1,'FontSize',14,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14],...
    'XTickLabel', xEtiquetas, 'XTickLabelRotation',45);
ylabel('Relative error [%]');

legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.75 0.65 0.082680591818973 0.263908701854494]);
    %'Position',[0.73585726718886 0.629101283880172 0.082680591818973 0.263908701854494]);
    

%% hold on
% hold on
% plot(0:15, ones(1,16)*median(reshape(allErrors(2:7,:), [1 6*14])), 'Color',[1 0 0], 'LineStyle', ':')
% hold off

print(gcf,'-dpng','/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/UuserVariability.png');
