function [aVascZone]=getThickTufts(thisMask, vesselSkelMask)

maskProps=regionprops(thisMask, 'Centroid', 'EquivDiameter');

%% Calculate using median filters


dist2vessels=bwdist(vesselSkelMask).*thisMask;

maskNoEdge=createCircularMask(size(thisMask, 1), size(thisMask, 2),...
    maskProps.Centroid(1), maskProps.Centroid(2), maskProps.EquivDiameter*.4);

emptyLbl=bwlabel(imbinarize(imerode(dist2vessels.*maskNoEdge,strel('disk',5))));

emptyProps=struct2table(regionprops(emptyLbl, dist2vessels, 'MaxIntensity', 'PixelIdxList', 'Area'));

mostEmptyLbL=find(emptyProps.MaxIntensity>3*std(emptyProps.MaxIntensity)+mean(emptyProps.MaxIntensity));

mostEmptyIm=zeros(size(thisMask));

for itEmpty=1:numel(mostEmptyLbL);
    mostEmptyIm(emptyProps.PixelIdxList{mostEmptyLbL(itEmpty)})=1;
end

pegoteados=logical(imclose(mostEmptyIm, strel('disk', 30)));
biggestObject=bwareafilt(pegoteados, 1);
aVascZone=imfill(biggestObject.*mostEmptyIm, 'holes');
