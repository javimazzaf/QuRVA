function msk = blocksToMask(sz, ind, blocks)

aux      = size(ind);
bSz      = aux(1:2);
nBlocks  = aux(3:4);

msk = zeros(bSz.*nBlocks);

for k = 1:size(blocks,1)
   msk(ind(:,:,blocks(k,1),blocks(k,2))) = true;
end

msk = msk(1:sz(1),1:sz(2));

end