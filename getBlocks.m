function [blocks, ind] = getBlocks(im, bSz)
    sz = size(im);
    
    % pad to produce an integer number of blocks
    nBlocks = ceil(sz ./ bSz);
    padSz   = nBlocks .* bSz - sz;
    
    im = padarray(im,padSz,0,'post');
    
    blocks = zeros([bSz nBlocks]);
    ind    = zeros([bSz nBlocks],'double');
    
    rgR = 1:bSz(1);
    rgC = 1:bSz(2);
    
    ix = double(im);
    ix(:) = 1:numel(ix);
    
    for r = 1:nBlocks(1)
        for c = 1:nBlocks(2)
           blocks(:,:,r,c) = im((r-1) * bSz(1) + rgR,(c-1) * bSz(2) + rgC); 
           ind(:,:,r,c)    = ix((r-1) * bSz(1) + rgR,(c-1) * bSz(2) + rgC); 
        end
    end
    
end