function outMask=testSURF(myImage, maskNoCenter, thisMask)

scaleFactor=3;

myMask=maskNoCenter.*thisMask;

outMask=zeros(size(myMask));

allPoints = detectSURFFeatures(myImage, 'NumOctaves', 5);

h=histogram(allPoints.Scale, 10);


for it=2:h.NumBins
    theseBlobs=allPoints(allPoints.Scale>h.BinEdges(it) & allPoints.Scale<h.BinEdges(it+1) & allPoints.SignOfLaplacian<0);
    
    if h.Values(it)>30
        theseBlobsGood=theseBlobs(theseBlobs.Metric>multithresh(theseBlobs.Metric));    
    else
        theseBlobsGood=theseBlobs(theseBlobs.Metric>mean(theseBlobs.Metric));
    end
    
    blobsMask=zeros(size(myImage));
    
    theseLocations=sub2ind(size(myImage), uint16(theseBlobsGood.Location(:,2)), ...
        uint16(theseBlobsGood.Location(:,1)));
    
    blobsMask(theseLocations)=1;
    
    blobsMask=imdilate(blobsMask, strel('disk', round(double(2*h.BinEdges(it+1)))));
    
    outMask=outMask | blobsMask;
end

outMask=outMask & maskNoCenter;

% goodPoints=allPoints(allPoints.Metric>multithresh(allPoints.Metric) & (allPoints.Scale>3.5) & allPoints.SignOfLaplacian<0);
% 
% goodPointsInd=sub2ind(size(myImage), uint16(goodPoints.Location(:,2)), ...
%     uint16(goodPoints.Location(:,1)));
% 
% goodPointsIndInMask=find(myMask(goodPointsInd)==1);
% outMask=zeros(size(myImage));


% for it=1:numel(goodPointsIndInMask)
%     % disp([num2str(it) ' of ' num2str(numel(goodPointsIndInMask))])
%     
%     c0=round(double(goodPoints.Location(goodPointsIndInMask(it),1)));
%     r0=round(double(goodPoints.Location(goodPointsIndInMask(it),2)));
%     s0=round(scaleFactor*double(goodPoints(goodPointsIndInMask(it)).Scale));
%     
%     blobsMask(r0-s0:r0+s0, c0-s0:c0+s0)=1;
%     
% %     %blobCenters=createCircularMask(size(myImage, 1), size(myImage, 2), ...
% %         double(goodPoints.Location(goodPointsIndInMask(it),1)),...
% %         double(goodPoints.Location(goodPointsIndInMask(it),2)), ...
% %         5*double(goodPoints(goodPointsIndInMask(it)).Scale));
% 
%     
%     %     blobCenters(goodPointsInd(goodPointsIndInMask(it)))=1;
% %     blobCenters=imdilate(blobCenters, strel('disk', round(double(goodPoints(goodPointsIndInMask(it)).Scale))));    
% end
% 
% outMask=logical(blobsMask.*myMask);
