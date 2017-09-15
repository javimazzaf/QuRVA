function correlationBertan

imPath = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/';

allFiles = dir(fullfile(imPath,'Masks','*.mat'));
allFiles = {allFiles(:).name};

% If the first 50 images where used for training, just use images from 51
% and on
allFiles = allFiles(51:end);

idQuRVA = regexp(allFiles,'([0-9]+_[a-zA-Z]+)(?=_original\.tif\.mat)','match');

baseSwift = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/';

area = NaN(numel(idQuRVA),2);

for k = 1:numel(idQuRVA)
    fileQurva = fullfile(imPath,'TuftNumbers/',[idQuRVA{k}{:} '_original.tif.mat']);
    fileSwift = fullfile(baseSwift,[idQuRVA{k}{:} '_manual.jpg']);
    
    if ~exist(fileQurva,'file') || ~exist(fileSwift,'file') || ~exist(fullfile('/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/Masks/',[idQuRVA{k}{:} '_original.tif.mat']),'file')  
        continue
    end
    
    thisMask = load(fullfile('/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/Masks/',[idQuRVA{k}{:} '_original.tif.mat']),'thisMask');
    thisMask = thisMask.thisMask;   
    
    thisONCenter = load(fullfile('/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/ONCenter/',[idQuRVA{k}{:} '_original.tif.mat']),'thisONCenter');
    thisONCenter = thisONCenter.thisONCenter; 
        
    maskQurva = load(fileQurva,'tuftsMask');
    maskQurva = maskQurva.tuftsMask;
    
    maskSwift = imread(fileSwift);
    
    maskQurva = resetScale(maskQurva);
    maskSwift = resetScale(maskSwift);
    [thisMask, scaleFactor] = resetScale(thisMask);    
    
    %Adjust sizes
    nRows = min([size(maskQurva,1),size(maskSwift,1), size(thisMask,1)]); 
    nCols = min([size(maskQurva,2),size(maskSwift,2), size(thisMask,2)]); 
    
    maskQurva = maskQurva(1:nRows,1:nCols);
    maskSwift = maskSwift(1:nRows,1:nCols) > 0;
    thisMask  = thisMask( 1:nRows,1:nCols);
    
    thisONCenter = thisONCenter/scaleFactor;
    
    [~, maskNoCenter] = processMask(thisMask, maskQurva, thisONCenter);
     
    validMask = maskNoCenter & thisMask;
    
    totalArea = sum(validMask(:));
    
    area(k,1) = sum(maskQurva(:) .* validMask(:)) / totalArea;
    area(k,2) = sum(maskSwift(:) .* validMask(:)) / totalArea;
    
    disp(k)
    
    imRes = uint8(cat(3,maskSwift & ~maskQurva, maskSwift & maskQurva, ~maskSwift & maskQurva) * 255);
    imRes = imoverlay(imRes,imdilate(bwperim(validMask),strel('disk',5)),'m');
    
end

area(isnan(area(:,1)) | isnan(area(:,2)),:) = [];

save('../compareSwiftQurva_Bertan.mat', 'area')

%% Plot
load('../compareSwiftQurva_Bertan.mat', 'area')

plot(area(:,1),area(:,2),'.k')

[R,P] = corrcoef(area(:,1),area(:,2))