function msk = getMask(im)

im(im(:) >= 0.99 * max(im(:))) = 0;

oSize = size(im);

scl = 500 / max(oSize);

% Scale down to speed up the processing
im = imresize(double(im), scl);

sz = round(100 * scl);

imLP   = mat2gray(filter2(fspecial('gaussian',[sz sz], sz/6),im));

thresh = getThreshold(imLP(:));
msk    = imbinarize(imLP,thresh);
[msk, cHull] = getBigestObject(msk);

% Refine binarization
thresh = getThreshold(imLP(cHull));

if isempty(thresh)
    msk    = imfill(msk,'holes');
    msk    = logical(imresize(msk, oSize));
    return
end


msk    = imbinarize(imLP,thresh);
[msk, ~] = getBigestObject(msk);

msk    = imfill(msk,'holes');

% Back to original size
msk    = logical(imresize(msk, oSize));

end