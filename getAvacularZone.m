function aVascZone = getAvacularZone(originalMask, vesselSkelMask, retinaDiam, thisONCenter)

readConfig

retinaMask   = imerode(originalMask,strel('disk',round(retinaDiam / 2 * avasc.erodeFraction)));

dist2vessels = bwdist(vesselSkelMask).*retinaMask;

maskNoEdge   = createCircularMask(size(retinaMask, 1), size(retinaMask, 2),...
                                  thisONCenter(1), thisONCenter(2),...
                                  retinaDiam / 2 * avasc.validRadiusFraction);

emptyLbl     = bwlabel(imbinarize(imerode(dist2vessels.*maskNoEdge,strel('disk',6))));

emptyProps   = regionprops('table', emptyLbl, dist2vessels, 'MaxIntensity', 'PixelIdxList', 'Area');

mostEmptyLbL = find(emptyProps.MaxIntensity>5*std(emptyProps.MaxIntensity)+mean(emptyProps.MaxIntensity));

mostEmptyIm  = zeros(size(retinaMask));

for itEmpty=1:numel(mostEmptyLbL)
    mostEmptyIm(emptyProps.PixelIdxList{mostEmptyLbL(itEmpty)}) = true;
end

aVascZone = logical(imclose(mostEmptyIm, strel('disk', avasc.closingSize)));

aVascZone = imfill(aVascZone, 'holes');

end