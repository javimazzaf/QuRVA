function szMax = computeRetinaSize(mask, center)

    [r,c] = find(bwperim(mask)>0.5);

    ind = convhull(c,r);
    
    c = c(ind);
    r = r(ind);

    d = sqrt((r - center(2)).^2 + (c - center(1)).^2); 

    szMax = mean(d) * 2;

end
