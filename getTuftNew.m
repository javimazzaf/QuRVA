function [msk, mskCoarse, mskIntens] = getTuftNew(inIm, vascMask)

readConfig;

[or, oc] = size(inIm);

sz = tufts.lowpassFilterSize * tufts.resampleScale;

sgm = sz / sqrt(2);

ker1 =   fspecial('gaussian', ceil(0.5 * 6) * [1 1] , 0.5);
ker2 = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
ker3 =   fspecial('disk', round(sgm * 0.75)) > 0;

thisImage = imresize(inIm,tufts.resampleScale);

bp1 = mat2gray(max(filter2(ker1,thisImage,'same'),0));
bp2 = mat2gray(max(filter2(ker2,thisImage,'same'),0));

vascMask = imresize(vascMask,tufts.resampleScale);

mskCoarse = bp2 >= double(median(bp2(vascMask)));
mskIntens = bp1 >= double(median(bp1(vascMask)));

nElements = sum(ker3(:));
mskMoreThanPerc = filter2(ker3,mskIntens,'same') / nElements > tufts.intensePixelsFraction;

mskCoarse = imresize(mskCoarse,[or, oc]);
mskIntens = imresize(mskIntens,[or, oc]);
mskMoreThanPerc = imresize(mskMoreThanPerc,[or, oc]);

msk = mskCoarse & mskMoreThanPerc;

msk = bwareaopen(msk,tufts.openingArea);

end