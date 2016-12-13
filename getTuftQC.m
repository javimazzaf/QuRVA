function outMask = getTuftQC(varargin)

% getTuftQC(myImage, thisMask, maskNoCenter, tuftsMask, smoothVessels)

myImage=varargin{1};
thisMask=varargin{2};
maskNoCenter=varargin{3};
tuftsMask=varargin{4};

if nargin==5 
    thickMask=varargin{5};
else
    thickMask = getThickVessels(myImage, thisMask, maskNoCenter);
end

tuftsMaskProps = struct2table(regionprops(logical(tuftsMask), 'PixelIdxList'));

for k = 1:numel(tuftsMaskProps)
    ix = tuftsMaskProps.PixelIdxList{k};
    valid(k) = logical(sum(thickMask(ix)) > 2);
end

validIxs = vertcat(tuftsMaskProps.PixelIdxList{valid'});

outMask = zeros(size(tuftsMask),'logical');

outMask(validIxs) = true;