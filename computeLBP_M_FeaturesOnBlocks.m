function features = computeLBP_M_FeaturesOnBlocks(inIm,R,P,blocksInd,selBlocks, offSet, tolRng)

ixFeat = [1,10];

features = zeros(size(selBlocks,1),numel(ixFeat));

mapping = getmapping(P,'riu2');

sz       = size(blocksInd);
bSz      = sz(1:2);
nBlocks  = sz(3:4);

padSz   = nBlocks .* bSz - size(inIm) + offSet;
    
inIm = padarray(inIm,padSz,0,'post');

for k = 1:size(selBlocks,1)
    aux = inIm(blocksInd(:,:,selBlocks(k,1),selBlocks(k,2)));
    
    [~,~,~,~,~,h] = clbp(aux,R,P,mapping,'nh',tolRng);
    
    features(k,:) = h(ixFeat);
end

end