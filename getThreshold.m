function thresh = getThreshold(inIm)

[N,edges] = histcounts(inIm,(0:255)/255);

N = N / max(N);

otsuThresh = graythresh(inIm(:));

[pks,locs] = findpeaks(N); 

[~,ix] = sort(pks,'descend');

ixMx1 = min(locs(ix([1,2])));
ixMx2 = max(locs(ix([1,2])));

% plot(edges(1:end-1),N), hold on
% plot(edges([ixMx1, ixMx2]),N([ixMx1, ixMx2]),'or')

% [~,ixMx1] = max(N .* (edges(1:end-1) < otsuThresh));
% [~,ixMx2] = max(N .* (edges(1:end-1) >= otsuThresh));

absmin = prctile(N(ixMx1:ixMx2),2);
[~,ix]=min(N(ixMx1:ixMx2)-absmin);

absmin=N(ixMx1+ix-1);

ix = find(N <= absmin & edges(1:end-1) > edges(ixMx1)& edges(1:end-1) < edges(ixMx2), 1, 'first');

thresh = edges(ix);

if isempty(thresh)
  thresh = otsuThresh;
end

end