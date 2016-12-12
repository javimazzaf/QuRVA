% Detects the parts of vessels that are thicker than mean+3SD and use it as
% a method to discard false positives of the Tuft detection
function outMask = getThickVessels(myImage, thisMask,maskNoCenter)

maskProps=regionprops(thisMask, 'Centroid', 'EquivDiameter');

%% Testing new ways
% Get Vessels' skeleton
vessels        = imbinarize(myImage.*uint8(thisMask), adaptthresh(myImage.*uint8(thisMask), 'NeighborhoodSize', [51, 51]));
vesselsClean   = bwareaopen(vessels, 500);
smoothVessels  = imdilate(vesselsClean, strel('disk', 2));
vesselSkelMask = bwmorph(smoothVessels, 'thin', Inf);

% Delete the egde as a vessel
maskEdge = imdilate(bwperim(thisMask), strel('disk',5));
vesselSkelMask(maskEdge==1)=0;
vesselSkelMask = vesselSkelMask.*smoothVessels;

% Separate skeleton in segments
brchPts = bwmorph(vesselSkelMask, 'branchpoints');
brchPts = imdilate(brchPts, strel('disk', 2));
skelSegments = bwareaopen(vesselSkelMask & ~brchPts, 3);

%%% End Testing new ways

%% Calculate using median filters

% dst = bwdist(vesselSkelMask) .* smoothVessels .* maskNoCenter;
skelDist = bwdist(~smoothVessels) .* vesselSkelMask .* maskNoCenter;

maxThickness = imdilate(skelDist,strel('disk', 3));
aux = skelDist;
aux(aux==0) = inf;
minThickness = imerode(aux,strel('disk', 3));

imdif = (maxThickness - minThickness) .* vesselSkelMask;
imshow(imoverlay(imoverlay(myImage,vesselSkelMask,'b'),(imdif.*vesselSkelMask)>=3,'r'));
TENGO QUE SEGUIR PROBANDO ESTA IDEA

% nDist = 8;
% dstParts = dst > nDist;
% dstPartsGrow = imdilate(dstParts, strel('disk', nDist+2));
% test = BW .* dstPartsGrow;

% medFiltVessels=filter2(ones(50), double(BW),'same') > (50^2/2);
% medFiltVesselsClean=bwareaopen(medFiltVessels, round(maskProps.EquivDiameter/40));
% outMask=imdilate(medFiltVesselsClean, strel('disk', round(maskProps.EquivDiameter/1000)));