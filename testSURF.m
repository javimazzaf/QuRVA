function outMask=testSURF(myImage, maskNoCenter, thisMask)

scaleFactor=5;

myMask=maskNoCenter.*thisMask;

allPoints = detectSURFFeatures(myImage);
goodPoints=allPoints(and(allPoints.Metric>multithresh(allPoints.Metric),(allPoints.Scale>4)));

goodPointsInd=sub2ind(size(myImage), uint16(goodPoints.Location(:,1)), ...
    uint16(goodPoints.Location(:,2)));

goodPointsIndInMask=find(myMask(goodPointsInd)==1);
outMask=zeros(size(myImage));

blobsMask=zeros(size(myImage));

for it=1:numel(goodPointsIndInMask)
    % disp([num2str(it) ' of ' num2str(numel(goodPointsIndInMask))])
    
    c0=round(double(goodPoints.Location(goodPointsIndInMask(it),1)));
    r0=round(double(goodPoints.Location(goodPointsIndInMask(it),2)));
    s0=round(scaleFactor*double(goodPoints(goodPointsIndInMask(it)).Scale));
    
    blobsMask(r0-s0:r0+s0, c0-s0:c0+s0)=1;
    
%     %blobCenters=createCircularMask(size(myImage, 1), size(myImage, 2), ...
%         double(goodPoints.Location(goodPointsIndInMask(it),1)),...
%         double(goodPoints.Location(goodPointsIndInMask(it),2)), ...
%         5*double(goodPoints(goodPointsIndInMask(it)).Scale));

    
    %     blobCenters(goodPointsInd(goodPointsIndInMask(it)))=1;
%     blobCenters=imdilate(blobCenters, strel('disk', round(double(goodPoints(goodPointsIndInMask(it)).Scale))));    
end

outMask=logical(blobsMask.*myMask);
