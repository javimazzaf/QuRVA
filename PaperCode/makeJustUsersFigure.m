function makeJustUsersFigure(data, ylab)

axes1 = axes('Parent',gcf);

bars = bar(data','Parent',axes1);

xlabels = {};

for it=1:size(data,2)
    xlabels = [xlabels;['Image ' num2str(it)]];
end

for it=1:6

    clr = [0 it/size(data,1) 0];
    set(bars(it),'FaceColor',clr,'EdgeColor',clr, 'DisplayName',['User ' num2str(it)]);
    
end

set(axes1,'linewidth',2,'FontSize',16,'XTick',1:size(data, 2),...
    'XTickLabel', xlabels, 'XTickLabelRotation',45);

ylabel(ylab);

ymax = ceil(prctile(data(:),97)/100)*100;

ylim([0 ymax])

lh = legend(axes1,'show');

set(lh,'Location','northwest')

end