function outMask=getThickTufts(myImage, thisMask,maskNoCenter)

maskProps=regionprops(thisMask, 'Centroid', 'EquivDiameter');

%% Calculate using median filters

BW=imbinarize(myImage.*uint8(thisMask), 'adaptive', 'Sensitivity', 0.4);

imSkel=bwmorph(BW, 'thin', Inf);
dst = bwdist(imSkel) .* BW .* maskNoCenter;
nDist = 8;
dstParts = dst > nDist;
dstPartsGrow = imdilate(dstParts, strel('disk', nDist));
test = BW .* dstPartsGrow;

medFiltVessels=filter2(ones(50), double(BW),'same') > (50^2/2);
medFiltVesselsClean=bwareaopen(medFiltVessels, round(maskProps.EquivDiameter/40));
outMask=imdilate(medFiltVesselsClean, strel('disk', round(maskProps.EquivDiameter/1000)));