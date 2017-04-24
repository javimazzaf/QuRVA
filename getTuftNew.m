function [msk, mskCoarse, mskIntens] = getTuftNew(inIm, vascMask)

[or, oc] = size(inIm);

scl = 0.25;

sz = 50 * scl;
sgm = sz / 2 / sqrt(2);
ker1 = fspecial('gaussian', ceil(0.5 * 6) * [1 1] , 0.5);
ker2 = - fspecial('log', ceil(sgm * 2 * 8) * [1 1] , sgm * 2);

thisImage = imresize(inIm,scl);
    
    bp1 = filter2(ker1,thisImage,'same');
    bp1 = max(bp1,0);

    bp2 = filter2(ker2,thisImage,'same');
    bp2 = max(bp2,0);
    
%     multi = imresize(multi,[or, oc]);
    bp1   = mat2gray(imresize(bp1,[or, oc]));
    bp2   = mat2gray(imresize(bp2,[or, oc]));
    
    mskCoarse = bp2 >= double(median(bp2(vascMask)));
    mskIntens = bp1 >= double(median(bp1(vascMask)));
    
%     msk = mskCoarse & mskIntens;

    mskLessThanHalf = 

    msk = mskCoarse;
    
%     bp2 = mat2gray(imresize(bp2,[or, oc]));
    

end