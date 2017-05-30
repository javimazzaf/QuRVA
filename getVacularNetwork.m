function [vesselSkelMask, brchPts, smoothVessels, endPts]=getVacularNetwork(thisMask, myImage)

readConfig

%% Segment a very fine vessels

vessels=imbinarize(myImage.*uint8(thisMask), adaptthresh(myImage.*uint8(thisMask), 'NeighborhoodSize', vascNet.ThreshNeighborSize));

vesselsClean=bwareaopen(vessels, vascNet.OpeningSize);

smoothVessels=imdilate(vesselsClean, strel('disk', vascNet.DilatingRadius));

vesselSkelMask=bwmorph(smoothVessels, 'thin', Inf);

%% Delete the egde as a vessel
maskEdge=imdilate(bwperim(thisMask), strel('disk',5));

vesselSkelMask(maskEdge==1)=0;
vesselSkelMask=vesselSkelMask.*smoothVessels;

brchPts=bwmorph(vesselSkelMask, 'branchpoints');
endPts=bwmorph(vesselSkelMask, 'endpoints');
