function navigateFeatures

% readConfig
tufts.blockSizeFraction = 1 / 180;
tufts.blocksInMaskPercentage = 25;

load('model.mat','model')

imPath = '../Anonymous/';
% imPath = '/Users/javimazzaf/Dropbox (Biophotonics)/Francois/310117TOTM/';
% imPath = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/';


imN = 3;

maskFiles = dir(fullfile(imPath,'Masks','*.mat'));
maskFiles = {maskFiles(:).name};

allFiles = cellfun(@(x) x(1:end-4),maskFiles,'UniformOutput',false);

thisImage=imread(fullfile(imPath,allFiles{imN}));
redImage=thisImage(:,:,1);

%% Make 8 bits
if strcmp(class(redImage), 'uint16')
    redImage=uint8(double(redImage)/65535*255);
end

%% Load Mask and Center
load(fullfile(imPath,'Masks',maskFiles{imN}), 'thisMask');
load(fullfile(imPath,'ONCenter',maskFiles{imN}), 'thisONCenter');

[maskStats, maskNoCenter] = processMask(thisMask, redImage, thisONCenter);

[redImage, scaleFactor] = resetScale(redImage);
thisMask     = resetScale(thisMask);
maskNoCenter = resetScale(maskNoCenter);
thisONCenter = thisONCenter/scaleFactor;
retinaDiam   = computeRetinaSize(thisMask, thisONCenter);

%% Processing

blockSize = ceil(retinaDiam * tufts.blockSizeFraction) * [1 1];

[blk, indBlocks] = getBlocks(redImage, blockSize, [0 0]);

candidateBlocks  = getBlocksInMask(indBlocks, maskNoCenter & thisMask, tufts.blocksInMaskPercentage, [0 0]);

blockFeatures = computeBlockFeatures(redImage, maskNoCenter, thisMask, indBlocks, candidateBlocks,[],[0 0],thisONCenter);

y = predict(model, blockFeatures);

% goodBlocks = candidateBlocks((y > 0.5) & (blockFeatures(:,6) > 0.5),:);
goodBlocks = candidateBlocks(y > 0.5,:);

% [bgMean,bgStd] = getRobustLocalBackground(mat2gray(redImage), thisMask);
% countAbovePixels = filter2(ones(50),double(mat2gray(redImage) > (bgMean + 3*bgStd)),'same') / 50^2;

% hdisk = fspecial('disk',5) > 0;
% mn = filter2(hdisk,mat2gray(redImage)) / sum(hdisk(:)) .* thisMask;
% mn2 = filter2(hdisk,mat2gray(redImage).^2) / sum(hdisk(:)) .* thisMask;
%
% sd = sqrt(mn2 - mn.^2) .* thisMask;
% contrast = sd ./ mn;

tuftsMask = blocksToMask(size(redImage), indBlocks, goodBlocks, [0 0]);

tuftsMask = bwareaopen(tuftsMask,prod(blockSize) + 1);

lowSatLevel = 0.01 + sum(redImage(:) == min(redImage(:))) / numel(redImage);
highSatLevel = 0.99 - sum(redImage(:) == max(redImage(:))) / numel(redImage);

adjustedImage = imadjust(redImage,stretchlim(redImage,[lowSatLevel highSatLevel]));

normIm = overSaturate(redImage);

[bckgAve, bckgStd] = getRobustLocalBackground(normIm, thisMask);

normIm = mat2gray(normIm);

mskAbove = double(normIm > (bckgAve + 3*bckgStd));

countAbovePixels = filter2(ones(30),mskAbove,'same') / 30^2;

tuftsMask = tuftsMask & (countAbovePixels >= 0.8);
imRGB = cat(3, uint8(tuftsMask) .* adjustedImage,adjustedImage, adjustedImage);

visualizeMultiImages(imRGB,{normIm;bckgAve;mskAbove;countAbovePixels},100);

% figure(1); imshow(imRGB,[])
% 
% dc = datacursormode(1);
% 
% set(dc,'UpdateFcn',@onUpdate,'DisplayStyle','datatip',...
%     'SnapToDataVertex','off','Enable','on'); 
% 
% 
% function txt = onUpdate(~,event_obj)
% % Customizes text of data tips
% 
% cp = get(event_obj,'Position');
% txt = {['row: ',num2str(cp(2))],...
% 	   ['col: ',num2str(cp(1))]};
%    
% bRow = floor(cp(2) ./ blockSize(2)) + 1; 
% bCol = floor(cp(1) ./ blockSize(1)) + 1; 
% 
% ix = find((candidateBlocks(:,1) == bRow) & (candidateBlocks(:,2) == bCol));
% feat = blockFeatures(ix,:);
% 
% int  = normIm(cp(2),cp(1));
% bgMn = bckgAve(cp(2),cp(1));
% bgSd = bckgStd(cp(2),cp(1));
% pixAb = countAbovePixels(cp(2),cp(1));
% 
% disp(' Local  | global  |   LOG   |  PIX    |  Int    |  bgMn   |  bgSd   |')
% f = '%1.5f';
% disp([num2str(feat(1),f) ' | ' num2str(feat(2),f) ' | '...
%       num2str(feat(3),f) ' | ' num2str(pixAb,f)   ' | '...
%       num2str(int,f)     ' | ' num2str(bgMn,f)    ' | '...
%       num2str(bgSd,f)    ' | '])
%   
% figure(1);
%    
% end

end