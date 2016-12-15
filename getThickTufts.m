function outMask=getThickTufts(myImage, thisMask)

readConfig

maskProps=regionprops(thisMask, 'Centroid', 'EquivDiameter');

%% Calculate using median filters
BW = imbinarize(myImage.*uint8(thisMask), 'adaptive', 'Sensitivity', tufts.thick.binSensitivity);

medFiltVessels = filter2(ones(tufts.thick.medFilterSize), double(BW),'same') > (tufts.thick.medFilterSize^2/2);
% medFiltVesselsClean=bwareaopen(medFiltVessels, round(maskProps.EquivDiameter/40));
% outMask=imdilate(medFiltVesselsClean, strel('disk', round(maskProps.EquivDiameter/1000)));

outMask = imdilate(medFiltVessels, strel('disk', round(maskProps.EquivDiameter/tufts.thick.DilatingRadiusDivisor)));