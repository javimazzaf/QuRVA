function brightVesselsRegions = getBrightTufts(varargin)

if nargin >= 2
    thisMask = varargin{2};
    redImage = varargin{1};
else
    error('Not enough parameters')
end

readConfig

maskProps = regionprops(thisMask, 'Centroid', 'EquivDiameter');

%% Adaptive threshold
BW = imbinarize(redImage.*uint8(thisMask), 'adaptive', 'Sensitivity', tufts.bright.binSensitivity);

%% Discard small objects
thisVessels = bwareaopen(BW, round(maskProps.EquivDiameter/tufts.bright.OpeningSizeDivisor1));

%% Calculate among foreground pixels an Otsu threshold

bV=im2bw(uint8(thisVessels).*redImage, graythresh(nonzeros(uint8(thisVessels).*redImage)));

brightVessels = bwareaopen(bV, round(maskProps.EquivDiameter/tufts.bright.OpeningSizeDivisor2));

brightVesselsRegions = imdilate(brightVessels, strel('disk', round(maskProps.EquivDiameter/tufts.bright.DilatingRadiusDivisor)));

end

