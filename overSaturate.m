% Reshapes the image histogram so that percBelow and percAbove pixels are
% saturated, additionally to the already saturated pixels.

function outIm = overSaturate(imIm,percBelow,percAbove)

if ~exist('percBelow','var'), percBelow = 0.01; end
if ~exist('percAbove','var'), percAbove = 0.99; end

lowSatLevel  = percBelow + sum(imIm(:) == min(imIm(:))) / numel(imIm);
highSatLevel = percAbove - sum(imIm(:) == max(imIm(:))) / numel(imIm);

outIm = imadjust(mat2gray(imIm),stretchlim(imIm,[lowSatLevel highSatLevel]));

end