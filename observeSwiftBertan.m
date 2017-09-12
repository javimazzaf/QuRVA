function observeSwiftBertan

resDir = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/visualSwift/';
if ~exist('resDir','dir')
    mkdir(resDir);
end

baseOrig = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/';
dirsOrig = dir(fullfile(baseOrig,'*original.tif'));

baseSwift = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/';

id = regexp({dirsOrig(:).name},'([0-9]+_[a-zA-Z]+)(?=_original\.tif)','match');

for k = 1:numel(id)
    fileOrig  = fullfile(baseOrig,[id{k}{:} '_original.tif']);
    fileSwift = fullfile(baseSwift,[id{k}{:} '_manual.jpg']);
    
    if ~exist(fileOrig,'file') || ~exist(fileSwift,'file')
        continue
    end
    
    imOrig = imread(fileOrig);
    imOrig = imOrig(:,:,1);
    
    mask = imread(fileSwift) > 0;
    
    %Crop it to the top-left if sizes dont match exactly
    if size(imOrig,2) < size(mask,2)
        mask = mask(:,1:size(imOrig,2));
    elseif size(imOrig,2) > size(mask,2)
        imOrig = imOrig(:,1:size(mask,2));
    end
    
    if size(imOrig,1) < size(mask,1)
        mask = mask(1:size(imOrig,1),:);
    elseif size(imOrig,1) > size(mask,1)
        imOrig = imOrig(1:size(mask,1),:);
    end
    
    lowSatLevel = 0.01 + sum(imOrig(:) == min(imOrig(:))) / numel(imOrig);
    highSatLevel = 0.99 - sum(imOrig(:) == max(imOrig(:))) / numel(imOrig);
    
    adjustedImage = imadjust(imOrig,stretchlim(imOrig,[lowSatLevel highSatLevel]));
    
    quadNW = cat(3, uint8(mask) .* adjustedImage,adjustedImage, adjustedImage);
    quadNE = cat(3, adjustedImage, adjustedImage, adjustedImage);
    
    imwrite([quadNW quadNE], fullfile(resDir,[id{k}{:} '.jpg']), 'JPG')
    
end

area(isnan(area(:,1)) | isnan(area(:,2)),:) = [];

save('../compareSwiftQurva_Bertan.mat', 'area')

%% Plot
load('../compareSwiftQurva_Bertan.mat', 'area')

plot(area(:,1),area(:,2),'.k')

[R,P] = corrcoef(area(:,1),area(:,2))