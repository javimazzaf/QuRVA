function [tuftsMask, brightMask, thickMask]=getTufts(thisMask, myImage, maskNoCenter)


%% Calculate tufts based on intensity only

brightMask=logical(getBrightTufts(myImage, thisMask)).*maskNoCenter;
% brightMask=logical(getBrightTufts(uint8(mat2gray(double(myImage).^2)*255), thisMask)).*maskNoCenter;

thickMask=logical(getThickTufts(myImage, thisMask)).*maskNoCenter;

tuftsMask=brightMask.*thickMask;


