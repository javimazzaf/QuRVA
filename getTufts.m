function [tuftsMask, brightMask, thickMask]=getTufts(thisMask, myImage, maskNoCenter)


%% Calculate tufts based on intensity only

brightMask=logical(getBrightTufts(myImage, thisMask)).*maskNoCenter;

thickMask=logical(getThickTufts(myImage, thisMask)).*maskNoCenter;

tuftsMask=brightMask.*thickMask;





