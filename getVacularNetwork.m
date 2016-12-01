function [vesselSkelMask, brchPts]=getVacularNetwork(thisMask, myImage)


%% Segment a very fine vessels

vessels=imbinarize(myImage.*uint8(thisMask), adaptthresh(myImage.*uint8(thisMask), 'NeighborhoodSize', [51, 51]));

vesselsClean=bwareaopen(vessels, 500);

smoothVessels=imdilate(vesselsClean, strel('disk', 2));

vesselSkelMask=bwmorph(smoothVessels, 'thin', Inf);

%% Delete the egde as a vessel
maskEdge=imdilate(bwperim(thisMask), strel('disk',5));

vesselSkelMask(maskEdge==1)=0;
vesselSkelMask=vesselSkelMask.*smoothVessels;

brchPts=bwmorph(vesselSkelMask, 'branchpoints');
