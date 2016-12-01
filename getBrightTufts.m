function brightVesselsRegions=getBrightTufts(varargin)

if nargin==2
    thisMask=varargin{2};
    redImage=varargin{1};
else
    load('/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/Masks/22G-conv.jpg.mat');
    redImage=imread('/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/22G-conv.jpg');
end
   
maskProps=regionprops(thisMask, 'Centroid', 'EquivDiameter');


%% Adaptive threshold
BW=imbinarize(redImage.*uint8(thisMask), 'adaptive', 'Sensitivity', 0.4);

%% Discard small objects
thisVessels=bwareaopen(BW, round(maskProps.EquivDiameter/100));

%% Calculate among foreground pixels an Otsu threshold

bV=im2bw(uint8(thisVessels).*redImage, graythresh(nonzeros(uint8(thisVessels).*redImage)));


brightVessels=bwareaopen(bV, round(maskProps.EquivDiameter/20));

brightVesselsRegions=imdilate(brightVessels, strel('disk', round(maskProps.EquivDiameter/1000)));

brightVesselsRegions=brightVesselsRegions;



end

