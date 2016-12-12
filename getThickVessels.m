% Detects the parts of vessels that are thicker than mean+3SD and use it as
% a method to discard false positives of the Tuft detection
function outMask = getThickVessels(myImage, thisMask,maskNoCenter)

maskProps=regionprops(thisMask, 'Centroid', 'EquivDiameter');

% Get Vessels' skeleton
vessels        = imbinarize(myImage.*uint8(thisMask), adaptthresh(myImage.*uint8(thisMask), 'NeighborhoodSize', [51, 51]));
vesselsClean   = bwareaopen(vessels, 500);
smoothVessels  = imdilate(vesselsClean, strel('disk', 2));
vesselSkelMask = bwmorph(smoothVessels, 'thin', Inf);

% Delete the egde as a vessel
maskEdge = imdilate(bwperim(thisMask), strel('disk',5));
vesselSkelMask(maskEdge==1)=0;
vesselSkelMask = vesselSkelMask.*smoothVessels;

%% Calculate using median filters

% dst = bwdist(vesselSkelMask) .* smoothVessels .* maskNoCenter;
skelDist = bwdist(~smoothVessels) .* vesselSkelMask .* maskNoCenter;

outMask = skelDist >= (mean(nonzeros(skelDist(:))) + 3 * std(nonzeros(skelDist(:))));


