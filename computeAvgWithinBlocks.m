function features = computeAvgWithinBlocks(inIm,blocksInd,selBlocks)

features = zeros(size(selBlocks,1),1);

sz       = size(blocksInd);
bSz      = sz(1:2);
nBlocks  = sz(3:4);

padSz   = nBlocks .* bSz - size(inIm);
    
inIm = padarray(inIm,padSz,0,'post');

for k = 1:size(selBlocks,1)
    aux = inIm(blocksInd(:,:,selBlocks(k,1),selBlocks(k,2)));
    features(k) = mean(aux(:));
end

end