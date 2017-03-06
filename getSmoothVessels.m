function smoothVessels = getSmoothVessels(thisMask, myImage)
%% Segment a very fine vessels

readConfig

vessels = imbinarize(myImage.*uint8(thisMask), adaptthresh(myImage.*uint8(thisMask), 'NeighborhoodSize', vascNet.ThreshNeighborSize));

vesselsClean = bwareaopen(vessels, vascNet.OpeningSize);

% smoothVessels = imdilate(vesselsClean, strel('disk', vascNet.DilatingRadius));
smoothVessels = imclose(vesselsClean, strel('disk', 1));
% smoothVessels = vesselsClean;
end