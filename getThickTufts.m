function outMask=getThickTufts(myImage, thisMask)

readConfig

testIm = double(myImage.*uint8(thisMask));
testIm = mat2gray(testIm);

vascMask  = imbinarize(mat2gray(bpass(testIm,1,5)));

threshold = median(testIm(vascMask));

enhancedTufts = filter2(fspecial('disk',tufts.thick.medFilterSize/2), testIm,'same');
outMask = enhancedTufts >= threshold;

outMask = imdilate(outMask, strel('disk', round(tufts.thick.medFilterSize/2)));
