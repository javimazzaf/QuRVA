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


exclude = [excludeBroken;trainingImages;excludeSwift];

load('../compareSwiftQurva_Bertan.mat', 'area','idQuRVA','allFiles','funcName','versionInfo')

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
disp(['R=' num2str(R(1,2),'%0.3f') ' - p=' num2str(P(1,2),'%0.10f')]);

fg = figure;
plot(set1,set2,'ok','MarkerSize',4,'MarkerEdgeColor',[0 0.2 .9],'MarkerFaceColor',[0 0.5 1]), hold on
plot(set1,fitSet2,'-','LineWidth',2,'Color',[1 0.3 0])
set(gca,'FontSize',16,'LineWidth',2,'XTick',0:0.05:0.15,'YTick',0:0.05:0.15)
xlim([0 0.16])
ylim([0 0.16])
xlabel('Area QuRVA / RA')
ylabel('Area Swift\_NV / RA')

ci = confint(f,0.95);

fitText = { 'y = m \cdot x + b';...
           ['m = ' num2str(f.p1,'%0.2f') ' \pm ' num2str(abs(ci(1,1)-ci(2,1))/2,'%0.2f')];...
           ['b = ' num2str(f.p2,'%0.2f') ' \pm ' num2str(abs(ci(1,2)-ci(2,2))/2,'%0.2f')]};

text(0.1,0.03,fitText,'FontSize',16)

imComment =  ['Function used to create image:' funcName '. '...
              'Soft git version: '...
              'Branch: ' versionInfo.branch '. '...
              'Sha: ' versionInfo.sha '. '...
              'QuRVA used model trained with our 20 anonymous images and: '...
              strjoin(trainingImages,'|')
              ];
      
figure2HQpng(fg,'../compareSwiftQurva_Bertan.png',imComment);




