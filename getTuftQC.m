function outMask = getTuftQC(varargin)
% getTuftQC(myImage, thisMask, maskNoCenter, tuftsMask, smoothVessels)

if nargin < 4, error('Not enough input parameters.'), end

myImage      = varargin{1};
thisMask     = varargin{2};
maskNoCenter = varargin{3};
inMask       = varargin{4};

outMask = thisMask;

readConfig

if nargin >= 5, thickMask = varargin{5};
else          , thickMask = getThickVessels(myImage, thisMask, maskNoCenter); end

tuftsMaskProps = struct2table(regionprops(logical(inMask), 'PixelIdxList'));

if isempty(tuftsMaskProps), return, end

for k = 1:numel(tuftsMaskProps)
    ix = tuftsMaskProps.PixelIdxList{k};
    valid(k) = logical(sum(thickMask(ix)) >= tufts.qc.minThickPixels);
end

validIxs = vertcat(tuftsMaskProps.PixelIdxList{valid'});

outMask = zeros(size(inMask),'logical');

outMask(validIxs) = true;