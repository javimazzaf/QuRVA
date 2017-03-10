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
% Enhance healthy (thin) vesses using a band-pass filter
bandPass = max(0,imgfilt(rawImageNorm,tufts.bandPassSizes(1)) - imgfilt(rawImageNorm,tufts.bandPassSizes(2)));

% Computes an adaptive (mean) threshold for the band-pass
thresh = filter2(fspecial('disk',tufts.bandPassSizes(2)), bandPass,'same');

% Binarizes the band-pass and remove small objects
vesselsMask = bwareaopen(bandPass >= thresh,25);

% Computes background mask for later
bckgMask    = ~vesselsMask & thisMask;


% Remove the edges of the mask from the healty vessels' mask
vesselsMask = vesselsMask & imerode(thisMask,strel('disk',100));

% Gets the skeleton and branching points of the healty vessels
vesselSkel = bwmorph(vesselsMask, 'thin', Inf);
brchPts    = bwmorph(vesselSkel, 'branchpoints');

% Separate branches in different objects to remove the short vessels
choppedSkel = vesselSkel & ~imdilate(brchPts,strel('disk',2));
longBranchesSkel = bwareaopen(choppedSkel,tufts.minVesselLength);

% Creates an image the same size of longBranchesSkel where each vessel has
% it size. This is used as a weight, since longer vessels are expected to
% be healtier.
sizeSkel = zeros(size(longBranchesSkel));
rgProps = regionprops(longBranchesSkel,'PixelIdxList','Area');
for k = 1:numel(rgProps)
    sizeSkel(rgProps(k).PixelIdxList) = rgProps(k).Area;
end

% Compute the thickness of vessels
vesselDist = bwdist(~vesselsMask);

% Estimates the overall thickness of healty vessels (mode + std)
vesselRadius    = double(mode(nonzeros(vesselDist .* vesselSkel)));
vesselRadiusStd = double(std(nonzeros(vesselDist .* vesselSkel)));

% Mask with thin, long, chopped vessels
modeVesselsMask = longBranchesSkel & (vesselDist < (vesselRadius + vesselRadiusStd));

%Make size image valid only on the thin vessels
sizeSkel = sizeSkel .* modeVesselsMask;

% Computes the binarization threshold with a scale 50 times the size of the
% vessels. It is the intensity average weighted using the length of the
% vessels. The longer the vessel, the more probable it is a real healthy
% vessel, and not some piece of tissue inside a tuft. 
ker = fspecial('disk',ceil(50*vesselRadius)) > 0;

sumValues = filter2(ker, rawImageNorm .* sizeSkel,'same');
sum2Values = filter2(ker, rawImageNorm.^2 .* sizeSkel,'same');
sumWeight = filter2(ker, sizeSkel,'same');
numValues = filter2(ker, modeVesselsMask,'same');

avgVesselIntensity = sumValues ./ sumWeight;

stdVesselIntensity = (sum2Values ./ sumWeight - avgVesselIntensity.^2);

% Background estimation
bckSum  = filter2(ker, rawImageNorm .* bckgMask,'same');
bckSum2 = filter2(ker, rawImageNorm.^2 .* bckgMask,'same');
bckNum  = filter2(ker, bckgMask,'same');

bckAve  = bckSum ./ bckNum;
bckStd  = sqrt(bckSum2 ./ bckNum - bckAve.^2);

% Clear outliers from background
mskOutliers = (rawImageNorm .* bckgMask) > (bckAve + 3 * bckStd);
bckgMask    = bckgMask & ~mskOutliers;

% Get Final background
bckSum  = filter2(ker, rawImageNorm .* bckgMask,'same');
bckSum2 = filter2(ker, rawImageNorm.^2 .* bckgMask,'same');
bckNum  = filter2(ker, bckgMask,'same');
bckAve  = bckSum ./ bckNum;
bckStd  = sqrt(bckSum2 ./ bckNum - bckAve.^2);

factor = sqrt(vesselRadius^2 / (tufts.lowpassFilterSize^2 + vesselRadius^2));
vesselThreshold = (avgVesselIntensity + 3 * stdVesselIntensity - bckAve + bckStd ) * factor + bckAve + bckStd;


% 
% vesselThreshold = (avgVesselIntensity + 3 * stdVesselIntensity) * factor;

outMask = lowpass >= vesselThreshold &...  % Threshold on the lowpass
          lowpass > 0.2 &... % If the signal is too dim it may be noise
          numValues >= 5 &... % If the average is weak is unreliable
          maskNoCenter; % Only inside the retinal mask

% Debug
visualizeMultiImages(imoverlay(rawImageNorm,bwperim(outMask),'r'),...
                    {lowpass;...
                     rawImageNorm;...
                     vesselThreshold;...
                     stdVesselIntensity},...
                     100)      
      
thickMask = outMask;

tuftsMask = outMask;

% Procedure to get rid of false positives
% if nargin >= 4
%     tuftsMask=getTuftQC(rawImage, thisMask, maskNoCenter, tuftsMask, smoothVessels);
% else
%     tuftsMask=getTuftQC(rawImage, thisMask, maskNoCenter, tuftsMask);
% end





