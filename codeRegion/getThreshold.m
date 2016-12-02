function thresh = getThreshold(inIm)
    
    [N,edges] = histcounts(inIm,(0:255)/255);
    
    N = N / max(N);
    
%     figure(1);hold off
%     bar(edges(1:end-1),N)
%     ylim([0 1.1])
    
    otsuThresh = graythresh(inIm(:));
    
    [~,ixMx1] = max(N .* (edges(1:end-1) < otsuThresh));
    [~,ixMx2] = max(N .* (edges(1:end-1) >= otsuThresh));
    
    absmin = prctile(N(ixMx1:ixMx2),2);
    
    %     absmin = max(0.02, absmin + 0.02);
    
    ix = find(N < absmin & edges(1:end-1) > edges(ixMx1)& edges(1:end-1) < edges(ixMx2), 1, 'first');
%     hold on
%     line([otsuThresh otsuThresh],[0 1.1],'Color','r')
%     plot(edges(ixMx1),N(ixMx1),'*m')
%     plot(edges(ixMx2),N(ixMx2),'*m')
%     plot(edges(ix),N(ix),'or')
%     hold off
    
    thresh = edges(ix);

end