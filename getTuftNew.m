function [msk, mskCoarse, mskIntens] = getTuftNew(inIm, vascMask)

[or, oc] = size(inIm);

scl = 0.25;

sz = 30 * scl;
sgm = sz / sqrt(2);
ker1 = fspecial('gaussian', ceil(0.5 * 6) * [1 1] , 0.5);
ker2 = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
ker3 = fspecial('disk', round(sgm * 0.75)) > 0;

thisImage = imresize(inIm,scl);

bp1 = filter2(ker1,thisImage,'same');
bp1 = max(bp1,0);

bp2 = filter2(ker2,thisImage,'same');
bp2 = max(bp2,0);

% bp1   = imresize(bp1,[or, oc]);
% bp2   = imresize(bp2,[or, oc]);

bp1   = mat2gray(bp1);
bp2   = mat2gray(bp2);

vascMask = imresize(vascMask,scl);

mskCoarse = bp2 >= double(median(bp2(vascMask)));
mskIntens = bp1 >= double(median(bp1(vascMask)));

nElements = sum(ker3(:));
mskMoreThanPerc = filter2(ker3,mskIntens,'same') / nElements > 0.4;

mskCoarse = imresize(mskCoarse,[or, oc]);
mskIntens = imresize(mskIntens,[or, oc]);
mskMoreThanPerc = imresize(mskMoreThanPerc,[or, oc]);

% mskLessThanHalf =

msk = mskCoarse & mskMoreThanPerc;



end