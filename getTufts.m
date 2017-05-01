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

eqImage = equalizeBrightness(rawImageNorm, vascMask);

[or, oc] = size(eqImage);

sz = tufts.lowpassFilterSize * tufts.resampleScale;

sgm = sz / sqrt(2);

ker1 =   fspecial('gaussian', ceil(tufts.denoiseFilterSize * 6) * [1 1] , tufts.denoiseFilterSize);
ker2 = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
ker3 =   fspecial('disk', round(sgm * 0.75)) > 0;

thisImage = imresize(eqImage,tufts.resampleScale);

bp1 = mat2gray(max(filter2(ker1,thisImage,'same'),0));
bp2 = mat2gray(max(filter2(ker2,thisImage,'same'),0));

vascMask = imresize(vascMask,tufts.resampleScale);

mskCoarse = bp2 >= double(median(bp2(vascMask)));
mskIntens = bp1 >= double(median(bp1(vascMask)));

mskMoreThanPerc = filter2(ker3,mskIntens,'same') / sum(ker3(:)) > tufts.intensePixelsFraction;

msk = mskCoarse & mskMoreThanPerc;

msk = imresize(msk,[or, oc]);

thickMask = bwareaopen(msk,tufts.openingArea);

tuftsMask = logical(thickMask) .* maskNoCenter;

end







