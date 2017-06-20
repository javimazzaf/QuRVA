function szMax = computeRetinaDiam(mask)

[r,c] = find(mask > 0.5);

szMax = max(range(r),range(c));

end