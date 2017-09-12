function correlationBertan

baseQuRVA = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/TuftNumbers/';
dirsQuRVA = dir(fullfile(baseQuRVA,'*original.tif.mat'));
%10_A_original.tif.mat

baseSwift = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/';
dirsSwift = dir(fullfile(baseSwift, '*manual.jpg'));
%1_A_manual.jpg

% numberQuRVA = regexp({dirsQuRVA(:).name},'[0-9].+?(?=_[a-zA-Z].original\.tif\.mat)','match');
% letterQuRVA = regexp({dirsQuRVA(:).name},'(?<=.[0-9]_)[a-zA-Z]+?(?=_.*)','match');

idQuRVA = regexp({dirsQuRVA(:).name},'([0-9]+_[a-zA-Z]+)(?=_original\.tif\.mat)','match');

area = NaN(numel(idQuRVA),2);

for k = 1:numel(idQuRVA)
    fileQurva = fullfile(baseQuRVA,[idQuRVA{k}{:} '_original.tif.mat']);
    fileSwift = fullfile(baseSwift,[idQuRVA{k}{:} '_manual.jpg']);
    
    if ~exist(fileQurva,'file') || ~exist(fileSwift,'file') || ~exist(fullfile('/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/Masks/',[idQuRVA{k}{:} '_original.tif.mat']),'file')  
        continue
    end
    
    fullMask = load(fullfile('/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/Masks/',[idQuRVA{k}{:} '_original.tif.mat']),'thisMask');
    fullMask = fullMask.thisMask;
    
    maskQurva = load(fileQurva,'tuftsMask');
    maskQurva = maskQurva.tuftsMask;
    
    maskSwift = resetScale(imread(fileSwift)) > 0;
    
    fullMask  = resetScale(fullMask);
    
    %Crop it the left if sizes dont match exactly
    if size(maskQurva,2) < size(maskSwift,2) 
        maskSwift = maskSwift(:,1:size(maskQurva,2));
    elseif size(maskQurva,2) > size(maskSwift,2) 
        maskQurva = maskQurva(:,1:size(maskSwift,2));
        fullMask  = fullMask(:,1:size(maskSwift,2));
    end
    
    if size(maskQurva,1) < size(maskSwift,1) 
        maskSwift = maskSwift(1:size(maskQurva,1),:);
    elseif size(maskQurva,1) > size(maskSwift,1) 
        maskQurva = maskQurva(1:size(maskSwift,1),:);
        fullMask  = fullMask(1:size(maskSwift,1),:);
    end    
    
    if numel(maskQurva) ~= numel(maskSwift) || numel(fullMask) ~= numel(maskSwift)  
        continue
    end
    
    totalArea = sum(fullMask(:));
    
    area(k,1) = sum(maskQurva(:)) / totalArea;
    area(k,2) = sum(maskSwift(:)) / totalArea;
    
    disp(k)
%     imRes = uint8(cat(3,maskSwift & ~maskQurva, maskSwift & maskQurva, ~maskSwift & maskQurva) * 255);
%     imshow(imoverlay(imRes,imdilate(bwperim(fullMask),strel('disk',5)),'m'))
    
end

area(isnan(area(:,1)) | isnan(area(:,2)),:) = [];

save('../compareSwiftQurva_Bertan.mat', 'area')

%% Plot
load('../compareSwiftQurva_Bertan.mat', 'area')

plot(area(:,1),area(:,2),'.k')

[R,P] = corrcoef(area(:,1),area(:,2))