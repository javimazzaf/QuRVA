function makeNiceOffPixelFigure(offPixels)

axes1 = axes('Parent',gcf);
bar1 = bar(offPixels','Parent',axes1);
set(bar1(1),'FaceColor',[1 0.843137264251709 0]);
set(bar1(2:7),'FaceColor',[1 0 0]);
set(bar1(8:end),'FaceColor',[1 0.543137264251709 1]);

for it=1:size(offPixels, 2)
    xEtiquetas{it}=['Image ' num2str(it)];
end
set(axes1,'FontSize',14,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15],...
    'XTickLabel', xEtiquetas, 'XTickLabelRotation',45);
ylabel('\Delta Area / consensus area');