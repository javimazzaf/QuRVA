function features = computeLBPFeaturesOnBlocks(inIm,R,P,blocksInd,selBlocks)

ixFeat = [4 8 12 13] - 3;

features = zeros(size(selBlocks,1),numel(ixFeat));

mapping = getmapping(P,'riu2');

sz       = size(blocksInd);
bSz      = sz(1:2);
nBlocks  = sz(3:4);

padSz   = nBlocks .* bSz - size(inIm);
    
inIm = padarray(inIm,padSz,0,'post');

for k = 1:size(selBlocks,1)
    aux = inIm(blocksInd(:,:,selBlocks(k,1),selBlocks(k,2)));
    
    [CLBP_SH,~] = clbp(aux,R,P,mapping,'h');
    
    % Normalize histogram
    h = double(CLBP_SH) / sum(CLBP_SH); 
    
 
    features(k,:) = h(ixFeat);
end



end