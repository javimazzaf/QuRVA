function [aVascZone]=getAvacularZone(originalMask, vesselSkelMask)

paperFigure=false;

maskProps=regionprops(originalMask, 'Centroid', 'EquivDiameter');

retinaMask = imerode(originalMask,strel('disk',round(maskProps.EquivDiameter* 0.02)));

dist2vessels=bwdist(vesselSkelMask).*retinaMask;


maskNoEdge=createCircularMask(size(retinaMask, 1), size(retinaMask, 2),...
    maskProps.Centroid(1), maskProps.Centroid(2), maskProps.EquivDiameter*.3);

emptyLbl=bwlabel(imbinarize(imerode(dist2vessels.*maskNoEdge,strel('disk',6))));


emptyProps=regionprops('table', emptyLbl, dist2vessels, 'MaxIntensity', 'PixelIdxList', 'Area');

% mostEmptyLbL=find(emptyProps.MaxIntensity>3*std(emptyProps.MaxIntensity)+mean(emptyProps.MaxIntensity));

mostEmptyLbL=find(emptyProps.MaxIntensity>5*std(emptyProps.MaxIntensity)+mean(emptyProps.MaxIntensity));

mostEmptyIm=zeros(size(retinaMask));

for itEmpty=1:numel(mostEmptyLbL);
    mostEmptyIm(emptyProps.PixelIdxList{mostEmptyLbL(itEmpty)})=1;
end

% aVascZone  = mostEmptyIm;

aVascZone = logical(imclose(mostEmptyIm, strel('disk', 15)));

aVascZone = imfill(aVascZone, 'holes');

% pegoteados = logical(imclose(mostEmptyIm, strel('disk', 30)));

% biggestObject=bwareafilt(pegoteados, 1);
% aVascZone=imfill(biggestObject.*mostEmptyIm, 'holes');
%%
if paperFigure
    niceLbl=bwlabel(imbinarize(imerode(dist2vessels,strel('disk',5))));
    statsMask=regionprops(originalMask, 'BoundingBox');
    imwrite(imcrop(label2rgb(niceLbl, 'prism', 'k'), statsMask.BoundingBox), '/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/aVascularObjects.jpg', 'jpg')
    imwrite(imcrop(imadjust(mat2gray(dist2vessels),[0; 1], [.1; 1]).*originalMask,statsMask.BoundingBox), '/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/vascularDistance.jpg', 'jpg');
    imwrite(imcrop(aVascZone|imdilate(bwperim(originalMask), strel('disk',4)), statsMask.BoundingBox), '/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/Manuscript/Figures/aVascularZone.jpg', 'jpg')
end