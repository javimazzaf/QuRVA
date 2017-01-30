function [aVascZone]=getAvacularZone(originalMask, vesselSkelMask)

maskProps=regionprops(originalMask, 'Centroid', 'EquivDiameter');

retinaMask = imerode(originalMask,strel('disk',round(maskProps.EquivDiameter* 0.02)));


dist2vessels=bwdist(vesselSkelMask).*retinaMask;

maskNoEdge=createCircularMask(size(retinaMask, 1), size(retinaMask, 2),...
    maskProps.Centroid(1), maskProps.Centroid(2), maskProps.EquivDiameter*.4);

emptyLbl=bwlabel(imbinarize(imerode(dist2vessels.*maskNoEdge,strel('disk',5))));

emptyProps=struct2table(regionprops(emptyLbl, dist2vessels, 'MaxIntensity', 'PixelIdxList', 'Area'));

% mostEmptyLbL=find(emptyProps.MaxIntensity>3*std(emptyProps.MaxIntensity)+mean(emptyProps.MaxIntensity));
mostEmptyLbL=find(emptyProps.MaxIntensity>4*std(emptyProps.MaxIntensity)+mean(emptyProps.MaxIntensity));

mostEmptyIm=zeros(size(retinaMask));

for itEmpty=1:numel(mostEmptyLbL);
    mostEmptyIm(emptyProps.PixelIdxList{mostEmptyLbL(itEmpty)})=1;
end

% aVascZone  = mostEmptyIm;

aVascZone = logical(imclose(mostEmptyIm, strel('disk', 15)));
% aVascZone = imfill(cerrado, 'holes');

% pegoteados = logical(imclose(mostEmptyIm, strel('disk', 30)));

% biggestObject=bwareafilt(pegoteados, 1);
% aVascZone=imfill(biggestObject.*mostEmptyIm, 'holes');
