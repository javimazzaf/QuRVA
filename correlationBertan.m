function correlationBertan

imPath = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/';

allFiles = dir(fullfile(imPath,'Masks','*.mat'));
allFiles = {allFiles(:).name};

% If the first 50 images where used for training, just use images from 51
% and on
allFiles = allFiles(51:end);

idQuRVA = regexp(allFiles,'([0-9]+_[a-zA-Z]+)(?=_original\.tif\.mat)','match');

baseSwift = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/';

% Columns: 1(QuRVA), 2(Swift), 3(Intersection), 4(Union), 5(Just QuRVA),
% 6(Just Swift), 7(dilated QuRVA)
area = NaN(numel(idQuRVA),7);

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
    
    area(k,1) = sum(maskQurva(validMask(:))) / totalArea;
    area(k,2) = sum(maskSwift(validMask(:))) / totalArea;
    area(k,3) = sum(maskQurva(validMask(:))  & maskSwift(validMask(:))) / totalArea;
    area(k,4) = sum(maskQurva(validMask(:))  | maskSwift(validMask(:))) / totalArea;
    area(k,5) = sum(maskQurva(validMask(:))  & ~maskSwift(validMask(:))) / totalArea;
    area(k,6) = sum(~maskQurva(validMask(:)) & maskSwift(validMask(:))) / totalArea;    
    disp(k)
    
    dilatedMask = imdilate(maskQurva,strel('disk',10));
    area(k,7) = sum(dilatedMask(validMask(:))) / totalArea;
    
    
%     imRes = uint8(cat(3,maskSwift & ~maskQurva, maskSwift & maskQurva, ~maskSwift & maskQurva) * 255);
%     imRes = imoverlay(imRes,imdilate(bwperim(validMask),strel('disk',5)),'m');
%     
%     imwrite(imRes,fullfile(imPath,'../correlations/',[idQuRVA{k}{:} '.png']),'png');
    
end

area(isnan(area(:,1)) | isnan(area(:,2)) | isnan(area(:,3)) | isnan(area(:,4)),:) = [];

save('../compareSwiftQurva_Bertan.mat', 'area')

%% Plot
load('../compareSwiftQurva_Bertan.mat', 'area')

% [R,P] = corrcoef(area(:,1),area(:,2))

% plot(area(:,1),area(:,2),'.k')
% xlabel('Area QuRVA [%]')
% ylabel('Area Swift [%]')
% % title()

figure;
areaSim = area(:,1) + area(:,1) .* randn(size(area(:,1))) * 0.7;
plot(area(:,1),areaSim,'.k')
[R,P] = corrcoef(area(:,1),areaSim)

% figure;
% plot(area(:,1),area(:,7),'.k')
% xlabel('Area QuRVA [%]')
% ylabel('Area QuRVA dilated [%]')
% [R2,P2] = corrcoef(area(:,1),area(:,7))
% title(['R=' num2str(R2(1,2)) '(p=' num2str(P2(1,2)) ')'])



% figure; bar(area');