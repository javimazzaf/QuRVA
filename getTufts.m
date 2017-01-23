function [tuftsMask, thickMask] = getTufts(varargin)

readConfig

if nargin < 3, error('Not enough input parameters.'), end

thisMask      = varargin{1};
rawImage      = varargin{2}; 
maskNoCenter  = varargin{3};

if nargin >= 4, smoothVessels = varargin{4}; end

rawImage = rawImage.*uint8(thisMask);
rawImageNorm = mat2gray(double(rawImage));

vascMask  = imbinarize(mat2gray(bpass(rawImageNorm,1,5)));

threshold = median(rawImageNorm(vascMask));

enhancedTufts = filter2(fspecial('disk',tufts.lowpassFilterSize/2), rawImageNorm,'same');
outMask = enhancedTufts >= threshold;

thickMask = imdilate(outMask, strel('disk', round(tufts.lowpassFilterSize/2)));

tuftsMask = logical(thickMask) .* maskNoCenter;

% Procedure to get rid of false positives
% if nargin >= 4
%     tuftsMask=getTuftQC(rawImage, thisMask, maskNoCenter, tuftsMask, smoothVessels);
% else
%     tuftsMask=getTuftQC(rawImage, thisMask, maskNoCenter, tuftsMask);
% end





