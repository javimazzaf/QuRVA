function features = computeLBPFeaturesOnBlocks(inIm,R,P,blocksInd,selBlocks)

features = zeros(size(selBlocks,1),P+2);

mapping = getmapping(P,'riu2');

sz       = size(blocksInd);
bSz      = sz(1:2);
nBlocks  = sz(3:4);

padSz   = nBlocks .* bSz - size(inIm);
    
inIm = padarray(inIm,padSz,0,'post');

for k = 1:size(selBlocks,1)
    aux = inIm(blocksInd(:,:,selBlocks(k,1),selBlocks(k,2)));
    
    [CLBP_SH,~] = clbp(aux,R,P,mapping,'h');
    
 
    features(k,:) = CLBP_SH;
end



end