function outMask=getThickTufts(myImage, thisMask,maskNoCenter)

readConfig

% maskProps=regionprops(thisMask, 'Centroid', 'EquivDiameter');

%% Calculate using median filters
% BW = imbinarize(myImage.*uint8(thisMask), 'adaptive', 'Sensitivity', tufts.thick.binSensitivity);
% 
% medFiltVessels = filter2(ones(tufts.thick.medFilterSize), double(BW),'same') > (tufts.thick.medFilterSize^2/2);
% % medFiltVesselsClean=bwareaopen(medFiltVessels, round(maskProps.EquivDiameter/40));
% % outMask=imdilate(medFiltVesselsClean, strel('disk', round(maskProps.EquivDiameter/1000)));
% 
% outMask = imdilate(medFiltVessels, strel('disk', round(maskProps.EquivDiameter/tufts.thick.DilatingRadiusDivisor)));

%% Version 1
% testIm = myImage.*uint8(thisMask);
% testIm = filter2(fspecial('disk',tufts.thick.medFilterSize/2), double(testIm),'same');
% testIm = mat2gray(testIm);
% outMask = im2bw(thisMask.*testIm, 0.5);

% %% Version 2
% testIm = double(myImage.*uint8(thisMask));
% testIm = mat2gray(testIm);
% 
% vascMask  = imbinarize(mat2gray(bpass(testIm,1,5)));
% 
% threshold = median(testIm(vascMask));
% 
% enhancedTufts = filter2(fspecial('disk',tufts.thick.medFilterSize/2), testIm,'same');
% outMask = im2bw(enhancedTufts, threshold);
% 
% outMask = imdilate(outMask, strel('disk', round(tufts.thick.medFilterSize/2)));

%% Version 3 - local threshold

sz = 20;
factor = 0.8;
testIm = double(myImage.*uint8(thisMask));
testIm = mat2gray(testIm);

vascIm = mat2gray(bpass(testIm,1,10));
vascMask  = imbinarize(vascIm);

threshold = median(testIm(vascMask));

vascReal = testIm;

vascReal(~vascMask) = 1i;
% vascReal(vascReal >= 0.97) = 1i;
% test = filter2(fspecial('disk',100), vascReal,'same');
test = conv2(ones(1,sz),ones(1,sz)',vascReal,'same');
suma  = real(test);
n     = sz^2 - imag(test);
media = suma ./ n; 
media(n<5) = 0;

% media = imopen(media,strel('disk',20));

enhancedTufts = filter2(fspecial('disk',tufts.thick.medFilterSize/2), testIm,'same');
outMask = (enhancedTufts > factor * media) & media > 0.1;
% outMaskOld = (enhancedTufts >= threshold);

% outMask = imdilate(outMask, strel('disk', round(tufts.thick.medFilterSize/2)));