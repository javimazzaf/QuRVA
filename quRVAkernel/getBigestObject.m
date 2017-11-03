function [msk,cHull] = getBigestObject(msk)

cHull = logical(zeros(size(msk)));

rgProps = regionprops(msk,'PixelIdxList','Area','ConvexImage','BoundingBox');

if numel(rgProps) > 1
    [~,ixBigest] = max([rgProps(:).Area]);
    
    msk   = logical(zeros(size(msk)));
    msk(rgProps(ixBigest).PixelIdxList) = true;
    
    aux = rgProps(ixBigest).ConvexImage;
    bb = rgProps(ixBigest).BoundingBox;
    
else
    
    aux = rgProps(1).ConvexImage;
    bb = rgProps(1).BoundingBox;
    
end

cHull(round(bb(2)+(0:bb(4)-1)),round(bb(1)+(0:bb(3)-1))) = logical(aux);

end
