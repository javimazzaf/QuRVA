function outMask=getTuftQC(tuftsMask)

outMask=tuftsMask;

outMask=bwareaopen(outMask, 30);

maskStats=struct2table(regionprops(logical(outMask), 'All'));

objLabeledImage=makeLabeledImage(logical(outMask));

%imshow(label2rgb(bwlabel(outMask), 'jet'))

thinObjects=find(maskStats.Solidity<.5);

bigObjects=find(maskStats.Area>mean(maskStats.Area));

for it=1:numel(bigObjects)
    thisObjSkel=bwmorph(maskStats.Image{bigObjects(it)}, 'thin', Inf);
    numBrchPts=sum(sum(bwmorph(thisObjSkel, 'branchpoints')));
    branchAreaRatio(it)=numBrchPts/maskStats.Area(bigObjects(it));
end

branchedObjects=find(branchAreaRatio>0.005);

for it=1:numel(branchedObjects)
    outMask(maskStats.PixelIdxList{bigObjects(branchedObjects(it))})=0;
end

elongatedObjects=find(maskStats.Eccentricity>.9);

imshow([outMask tuftsMask]);

