function outMask = getTuftQC(myImage, thisMask,maskNoCenter, tuftsMask)

thickMask = getThickVessels(myImage, thisMask,maskNoCenter);

tuftsMaskProps = struct2table(regionprops(logical(tuftsMask), 'PixelIdxList'));

for k = 1:numel(tuftsMaskProps)
    ix = tuftsMaskProps.PixelIdxList{k};
    valid(k) = logical(sum(thickMask(ix)) > 2);
end

validIxs = vertcat(tuftsMaskProps.PixelIdxList{valid'});

outMask = zeros(size(tuftsMask),'logical');

outMask(validIxs) = true;