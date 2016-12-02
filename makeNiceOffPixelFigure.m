function makeNiceOffPixelFigure(offPixels)

axes1 = axes('Parent',gcf);
bar1 = bar(offPixels','Parent',axes1);
set(bar1(1),'FaceColor',[1 0 0], 'DisplayName','FMA');
for it=1:6
    set(bar1(it+1),'FaceColor',[0 it*1/6 0], 'DisplayName',['Manual ' num2str(it+1)]);
end
for it=1:size(offPixels, 1)-7
    set(bar1(it+7),'FaceColor',[.6 .1 it*1/(size(offPixels, 2)-7)], 'DisplayName',['Swift ' num2str(it)]);
end

for it=1:size(offPixels, 2)
    xEtiquetas{it}=['Image ' num2str(it)];
end

set(axes1,'FontSize',14,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15],...
    'XTickLabel', xEtiquetas, 'XTickLabelRotation',45);
ylabel('Number of Off Pixels');

legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.285 0.55 0.082680591818973 0.263908701854494]);
    %'Position',[0.73585726718886 0.629101283880172 0.082680591818973 0.263908701854494]);
