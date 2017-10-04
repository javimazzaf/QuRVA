function [outImage, scaleFactor] = resetScale(inImage)

sz = size(inImage);

[~,ix] = max(sz);

newSize = [NaN NaN];
newSize(ix) = 4096;

layer1   = imresize(inImage(:,:,1),newSize);

if size(sz) == 3
    
    outImage = zeros([size(layer1) sz(3)]);
    outImage(:,:,1) = layer1;
    
    for k = 2:sz(3)
        outImage(:,:,k) = imresize(inImage(:,:,k),newSize);
    end
    
else
    
    outImage = layer1;
    
end

outSz=size(layer1);
scaleFactor=sz(1)/outSz(1);

end