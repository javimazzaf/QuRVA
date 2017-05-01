% function compareTuftResultsNew

% loads local parameters
readConfig;

mkdir(masterFolder, 'Global')

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

%% Load results

for it=1:numel(myFiles)
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask','allMasks')
    load(fullfile(masterFolder,'SwiftMasks',myFiles{it}),'swiftMasks')
    
    [consLabels, consNum]   = bwlabel(consensusMask > 0);
    [tuftsLabels, tuftsNum] = bwlabel(tuftsMask > 0);
    
    FNo(1,it) = numel(setdiff(1:consNum, unique(consLabels(:) .* tuftsMask(:))));
    FPo(1,it) = numel(setdiff(1:tuftsNum, unique(tuftsLabels(:) .* consensusMask(:))));
    
    % Automatic Method
    FP(1,it) = sum(tuftsMask(:) > consensusMask(:));
    FN(1,it) = sum(tuftsMask(:) < consensusMask(:));
    
    % Each Evaluator
    for itUsers=1:size(allMasks,3)
        FP(itUsers+1,it) = sum(sum(allMasks(:,:,itUsers) > consensusMask));
        FN(itUsers+1,it) = sum(sum(allMasks(:,:,itUsers) < consensusMask));
        
        [evLabels, evNum] = bwlabel(allMasks(:,:,itUsers) > 0);
    
        FNo(itUsers+1,it) = numel(setdiff(1:consNum, unique(consLabels(:) .* evLabels(:))));
        FPo(itUsers+1,it) = numel(setdiff(1:evNum, unique(evLabels(:) .* consensusMask(:))));        
        
    end
    
    % Each Swift
    for itSwift = 1:size(swiftMasks,3)
        
        %Check if I got zeros because the user did not analyze this image
        if max(max(swiftMasks(:,:,itSwift))) == 0
            FP(itUsers+1+itSwift,it) = NaN;
            FN(itUsers+1+itSwift,it) = NaN;
        else
            FP(itUsers+1+itSwift,it) = sum(sum(swiftMasks(:,:,itSwift) > consensusMask));
            FN(itUsers+1+itSwift,it) = sum(sum(swiftMasks(:,:,itSwift) < consensusMask));  
            
           [swLabels, swNum] = bwlabel(swiftMasks(:,:,itSwift) > 0);
    
           FNo(itUsers+1+itSwift,it) = numel(setdiff(1:consNum, unique(consLabels(:) .* swLabels(:))));
           FPo(itUsers+1+itSwift,it) = numel(setdiff(1:swNum, unique(swLabels(:) .* consensusMask(:))));              
            
        end
        
    end

end

FPothers = FP(2:end,:);
FNothers = FN(2:end,:);

FPoOthers = FPo(2:end,:);
FNoOthers = FNo(2:end,:);

save(fullfile(masterFolder,'comparisonOthers.mat'),'FPothers','FNothers','FPoOthers','FNoOthers')

nMethods = size(FP,1);

%% Testing

[~, iFP] = sort(FP);
[FPrate, ~] = find(iFP == 1);

nBetterFP = sum(nMethods - FPrate);

[~, iFN] = sort(FN);
[FNrate, ~] = find(iFN == 1);

nBetterFN = sum(nMethods - FNrate);

disp((nBetterFP+nBetterFN) / 336)

%% Make barplots
figure;
makeNiceOffPixelFigure(FPo)
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFPpixels.png'));
% 
figure;
makeNiceOffPixelFigure(FNo)
print(gcf,'-dpng',fullfile(masterFolder,'Global','BarplotFNpixels.png'));

% disp(nBetterFP+nBetterFN)

