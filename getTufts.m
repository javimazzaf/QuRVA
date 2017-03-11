function [tuftsMask, thickMask] = getTufts(varargin)

readConfig

if nargin < 3, error('Not enough input parameters.'), end

thisMask      = varargin{1};
rawImage      = varargin{2};
maskNoCenter  = varargin{3};

% Prepare raw data
rawImage = rawImage.*uint8(thisMask);
rawImageNorm = mat2gray(double(rawImage));

% Low-pass filter
lowpass  = imgfilt(rawImageNorm,tufts.lowpassFilterSize);

%% Computes typical brightness of healthy vasculature locally

% Computes an adaptive (mean) threshold for the band-pass
thresh = filter2(fspecial('disk',tufts.lowpassFilterSize), rawImageNorm,'same');

% Binarizes the band-pass and remove small objects
vesselsMask = bwareaopen(rawImageNorm >= thresh,25) & thisMask;

% Computes background mask for later
bckgMask    = ~vesselsMask & thisMask;

% % Remove the edges of the mask from the healty vessels' mask
% vesselsMask = vesselsMask & imerode(thisMask,strel('disk',100));

% Compute the thickness of vessels
vesselDist = bwdist(~vesselsMask);

% Estimates the overall thickness of healty vessels (mode + std)
vesselRadius    = double(mode(nonzeros(vesselDist .* vesselsMask)));
vesselRadiusStd = double(std(nonzeros(vesselDist .* vesselsMask)));

ker = fspecial('disk',2*ceil(2*tufts.lowpassFilterSize)+1) > 0;

sumVesselIntensity = filter2(ker, rawImageNorm .* vesselsMask,'same');
sumBackground      = filter2(ker, rawImageNorm .* bckgMask,'same');
numValues          = filter2(ker, vesselsMask,'same');
numBck             = sum(ker(:)) - numValues;

avgVesselIntensity = sumVesselIntensity ./ numValues;
avgBackground      = sumBackground ./ numBck;

factor = sqrt(vesselRadius^2 / (tufts.lowpassFilterSize^2 + vesselRadius^2));

vesselThreshold =  ((avgVesselIntensity - avgBackground) * factor + avgBackground);

outMask = lowpass * tufts.sensitivityFactor >= vesselThreshold &...  % Threshold on the lowpass
          lowpass > 0.2 &... % If the signal is too dim it may be noise
          maskNoCenter; % Only inside the retinal mask

% Debug
visualizeMultiImages(imoverlay(rawImageNorm,bwperim(outMask),'r'),...
                    {lowpass;...
                     rawImageNorm;...
                     vesselThreshold;...
                     lowpass * tufts.sensitivityFactor},...
                     100)      
      
thickMask = outMask;

tuftsMask = outMask;

% Procedure to get rid of false positives
% if nargin >= 4
%     tuftsMask=getTuftQC(rawImage, thisMask, maskNoCenter, tuftsMask, smoothVessels);
% else
%     tuftsMask=getTuftQC(rawImage, thisMask, maskNoCenter, tuftsMask);
% end





