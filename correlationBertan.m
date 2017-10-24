function correlationBertan

readConfig

funcName = mfilename;

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

baseDir = '/Volumes/EyeFolder/';
% baseDir = '~/';

imPath = fullfile(baseDir,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/');

allFiles = dir(fullfile(imPath,'Masks','*.mat'));
allFiles = {allFiles(:).name};

% If the first 50 images where used for training, just use images from 51
% and on
% allFiles = allFiles(51:end);

idQuRVA = regexp(allFiles,'([0-9]+_[a-zA-Z]+)(?=_original\.tif\.mat)','match');

baseSwift = fullfile(baseDir, 'Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/');

% Columns: 1(QuRVA), 2(Swift), 3(Intersection), 4(Union), 5(Just QuRVA),
% 6(Just Swift), 7(dilated QuRVA), 8(QuRVA-smoothVessels)
area = NaN(numel(idQuRVA),8);

for k = 1:numel(idQuRVA)

    fileQurva = fullfile(imPath,'TuftNumbers/',[idQuRVA{k}{:} '_original.tif.mat']);
    fileSwift = fullfile(baseSwift,[idQuRVA{k}{:} '_manual.jpg']);
    
    if ~exist(fileQurva,'file') || ~exist(fileSwift,'file') || ~exist(fullfile(baseDir, 'Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/Masks/',[idQuRVA{k}{:} '_original.tif.mat']),'file')  
        continue
    end
    
    thisMask = load(fullfile(baseDir, 'Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/Masks/',[idQuRVA{k}{:} '_original.tif.mat']),'thisMask');
    thisMask = thisMask.thisMask;   
    
    thisONCenter = load(fullfile(baseDir, 'Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/ONCenter/',[idQuRVA{k}{:} '_original.tif.mat']),'thisONCenter');
    thisONCenter = thisONCenter.thisONCenter; 
    
    load(fullfile(imPath,'VasculatureNumbers/',[idQuRVA{k}{:} '_original.tif.mat']),'smoothVessels');
        
    maskQurva = load(fileQurva,'tuftsMask');
    maskQurva = maskQurva.tuftsMask;
    
    maskSwift = imread(fileSwift) > 100;
    
    smoothVessels = resetScale(smoothVessels);
    maskQurva = resetScale(maskQurva);
    maskSwift = resetScale(maskSwift);
    [thisMask, scaleFactor] = resetScale(thisMask);   
    
    %Adjust sizes
    nRows = min([size(maskQurva,1),size(maskSwift,1), size(thisMask,1)]); 
    nCols = min([size(maskQurva,2),size(maskSwift,2), size(thisMask,2)]); 
    
    maskQurva     = maskQurva(1:nRows,1:nCols);
    maskSwift     = maskSwift(1:nRows,1:nCols);
    thisMask      = thisMask( 1:nRows,1:nCols);
    smoothVessels = smoothVessels(1:nRows,1:nCols);
    
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
    
    maskQurvaSmoothVessels = maskQurva & smoothVessels;
    area(k,8) = sum(maskQurvaSmoothVessels(validMask(:))) / totalArea;
    
    
%     imRes = uint8(cat(3,maskSwift & ~maskQurva, maskSwift & maskQurva, ~maskSwift & maskQurva) * 255);
%     imRes = imoverlay(imRes,imdilate(bwperim(validMask),strel('disk',5)),'m');
%     
%     imwrite(imRes,fullfile(imPath,'../correlations/',[idQuRVA{k}{:} '.png']),'png');
    
end

save('../compareSwiftQurva_Bertan.mat', 'area','idQuRVA','allFiles','funcName','versionInfo')

%% Plot

readConfig

excludeBroken = {'1_E';'5_D';'34_G';'34_Q';'34_J'};

excludeSwift = {...
'23_F';'29_B';'29_D';'29_E';'29_H';'29_I';'29_J';...
'29_L';'29_N';'29_O';'31_A';'32_A';'32_B';'32_G';'33_A';'33_B';...
'33_E';'33_F';'33_H';'33_J';'34_D';'34_H';...
'35_A';'35_C';'36_C';...
'37_B';'37_C';'37_D';'37_E';'37_G';'32_C';'29_C';...
'33_C';'34_C';'34_E';'34_R'...
};

% '35_B';'36_G';'34_I';'36_D';'36_E';'36_A';'36_H';'36_B'
% excludeDoubt = {...
% '6_C';'6_F';'9_C';'17_C';'23_K';'25_H';'25_J';...
% '26_F';'28_D';'28_H';'28_J';'29_F';'31_D';'31_E';'32_D';'33_G';...
% '34_A';'34_B';'34_K';'34_L';'34_M';'34_N';'34_O';...
% '34_P';'29_G';'29_K'};


exclude = [excludeBroken;trainingImages;excludeSwift];

% area(any(isnan(area)')',:) = [];
% 
% set1 = area(:,1);
% set2 = area(:,2);
% 
% f = fit(set1,set2,'poly1');
% fitSet2 = f(set1);
% 
% dist = abs(set2 - fitSet2);
% 
% [dist, ix] = sort(dist,'descend');
% set1 = set1(ix);
% set2 = set2(ix);
% fitSet2 = f(set1);

%Seleccion
% nGood = 170;
% set1    = set1(end-nGood+1:end);
% set2    = set2(end-nGood+1:end);
% fitSet2 = fitSet2(end-nGood+1:end);

% baseDir = '/Volumes/EyeFolder/';
% imPath = fullfile(baseDir,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/');
% allFiles = dir(fullfile(imPath,'Masks','*.mat'));
% allFiles = {allFiles(:).name};
% allFiles = allFiles(51:end);
% idQuRVA = regexp(allFiles,'([0-9]+_[a-zA-Z]+)(?=_original\.tif\.mat)','match');

load('../compareSwiftQurva_Bertan.mat', 'area','idQuRVA','allFiles')
% % 
% testMsk = ismember([idQuRVA{:}],excludeSwift');
% plot(area(testMsk,1),area(testMsk,2),'or')

%

validMsk = ~ismember([idQuRVA{:}],exclude');
validMsk = validMsk & ~any(isnan(area)');

area    = area(validMsk,:);
idQuRVA = idQuRVA(validMsk);
allFiles = allFiles(validMsk);

set1 = area(:,1);
set2 = area(:,2);
f = fit(set1,set2,'poly1');

fitSet2 = f(set1);

[R,P] = corrcoef(set1,set2);
disp(['R=' num2str(R(1,2),'%0.3f') ' - p=' num2str(P(1,2),'%0.3f')]);

plot(set1,set2,'.k'), hold on
plot(set1,fitSet2,'-r')
xlabel('Area QuRVA [%]')
ylabel('Area Swift [%]')

% 
% 
% disp('===================================================================')
% for k = 1:10
%     ix = find((round(area(:,1)*1E4)/1E4 == round(set1(k)*1E4)/1E4) & (round(area(:,2)*1E4)/1E4 == round(set2(k)*1E4)/1E4));
%     disp([allFiles{ix} 9 '|' 9 num2str(area(ix,3)) '|' 9 num2str(area(ix,5)) '|' 9 num2str(area(ix,6))])
% end
% disp('-------------------------------------------------------------------')
% for k = numel(set1):-1:numel(set1)-4
%     ix = find((round(area(:,1)*1E4)/1E4 == round(set1(k)*1E4)/1E4) & (round(area(:,2)*1E4)/1E4 == round(set2(k)*1E4)/1E4));
%     disp([allFiles{ix} 9 '|' 9 num2str(area(ix,3)) '|' 9 num2str(area(ix,5)) '|' 9 num2str(area(ix,6))])
% end



