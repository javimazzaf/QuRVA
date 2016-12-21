% testing

%% 
% medSize = tufts.thick.medFilterSize/2;
medSize = 8;

testIm = double(myImage.*uint8(thisMask));
testIm = mat2gray(testIm);

vascMask  = imbinarize(mat2gray(bpass(testIm,1,5)));
threshold = median(testIm(vascMask));

enhancedTufts = filter2(fspecial('disk',medSize), testIm,'same');
testMask = im2bw(enhancedTufts, threshold);

imRes = myImage;
% imRes = imoverlay(imRes,logical(bwperim(medFiltVessels)),'r');
imRes = imoverlay(imRes,logical(bwperim(testMask)),'r');

imshow(imRes)

%%
hist(nonzeros(enhancedTufts(:)),256), hold on
hist(nonzeros(testIm(vascMask)),256), hold on

%%
testIm = double(myImage.*uint8(thisMask));
testIm = mat2gray(testIm);

vascMask  = imbinarize(mat2gray(bpass(testIm,1,5)));
% vascMask  = bwareaopen(vascMask, 5);
% threshold = median(testIm(vascMask))
threshold = median(testIm(vascMask & maskNoCenter))

% imshow(imoverlay(imoverlay(myImage,vascMask,'m'),testIm > 0.9,'g'))

%% performance test
testName = '../localThresholdQCbeforeDilated.mat';
[FP, FN, TP] = measureTuftSegmentationPerformance;
save(testName,'FP','FN','TP');

%% show performance

load('../localThreshold.mat','FP','FN','TP');
FP1 = FP;
FN1 = FN;
TP1 = TP;
load('../localThresholdDilated.mat','FP','FN','TP');
FP2 = FP;
FN2 = FN;
TP2 = TP;
load('../VersionOri.mat','FP','FN','TP');
FP3 = FP;
FN3 = FN;
TP3 = TP;

load('../localThresholdQCbeforeDilated.mat','FP','FN','TP');
FP4 = FP;
FN4 = FN;
TP4 = TP;


figure; plot(FP1), hold on, plot(FP2), plot(FP3), plot(FP4), legend({'Local';'LocalDilated';'Ori';'QCbefore'})
figure; plot(FN1), hold on, plot(FN2), plot(FN3), plot(FN4), legend({'Local';'LocalDilated';'Ori';'QCbefore'})
figure; plot(TP1), hold on, plot(TP2), plot(TP3), plot(TP4), legend({'Local';'LocalDilated';'Ori';'QCbefore'})

%% Testing local threshold
sz = 20;
factor = 0.9;
testIm = double(myImage.*uint8(thisMask));
testIm = mat2gray(testIm);

vascIm = mat2gray(bpass(testIm,1,10));
vascMask  = imbinarize(vascIm);

threshold = median(testIm(vascMask));

vascReal = testIm;

vascReal(~vascMask) = i;
vascReal(vascReal >= 0.97) = i;
% test = filter2(fspecial('disk',100), vascReal,'same');
test = conv2(ones(1,sz),ones(1,sz)',vascReal,'same');
suma  = real(test);
n     = sz^2 - imag(test);
media = suma ./ n; 
media(n<5) = 0;

% media = imopen(media,strel('disk',20));

enhancedTufts = filter2(fspecial('disk',tufts.thick.medFilterSize/2), testIm,'same');
outMask = (enhancedTufts > factor * media) & media > 0.1;
outMaskOld = (enhancedTufts >= threshold);

figure;imshow(imoverlay(imoverlay(testIm,outMaskOld,'m'),outMask,'g'))
% figure;imshow(enhancedTufts,[])
% figure;imshow(media,[])

%% Interpolation testing
media = zeros(9);
media(4:6,4:6) = magic(3);
[X,Y] = meshgrid(1:size(media,2),1:size(media,2));
F = scatteredInterpolant(X(media ~= 0), Y(media ~= 0), media(media ~= 0),'nearest');
intMedia = F(X,Y);

%% Testing histograma vasos
testIm = double(myImage.*uint8(thisMask));
testIm = mat2gray(testIm);

vascIm = mat2gray(bpass(testIm,1,5));
vascMask  = imbinarize(vascIm);
hist(testIm(vascMask),256);


