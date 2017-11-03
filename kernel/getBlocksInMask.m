function selBlocks = getBlocksInMask(ix, msk, percTol, offSet)

selBlocks = [];
sz       = size(ix);
bSz      = sz(1:2);
nBlocks  = sz(3:4);

padSz   = nBlocks .* bSz - size(msk) + offSet;
    
msk = padarray(msk,padSz,0,'post');

for r = 1:nBlocks(1)
    for c = 1:nBlocks(2)
        if sum(sum(msk(ix(:,:,r,c))))/bSz(1)/bSz(2) >= (percTol / 100)
           selBlocks = [selBlocks;r c]; 
        end
    end
end

end