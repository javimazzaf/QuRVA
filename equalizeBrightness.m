function outIm = equalizeBrightness(inIm, vascMask)

[r,c] = find(vascMask);

szAll = max(range(r),range(c));

sz = round(szAll / 8);

ker = fspecial('average', sz) > 0;

nPix = sum(ker(:));

% sumC = filter2(ker,inIm .* vascMask);
% numC = filter2(ker,vascMask);
% 
% normCoeff = sumC ./ numC;

normCoeff = filter2(ker,inIm) / nPix;

outIm = inIm ./ normCoeff;

end