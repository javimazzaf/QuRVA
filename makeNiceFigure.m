function makeNiceFigure(data,yLab, legendON, yAxisLims)

users={'User 1' 'User 2' 'User 3' 'User 4' 'User 5' 'User 6'};

axes1 = axes('Parent',gcf);
bar1 = bar(data','Parent',axes1);
set(bar1(1),'FaceColor',[1 0 0], 'DisplayName','QuRVA');


for it=2:size(data, 1)
    set(bar1(it),'FaceColor',[0 2/9+it*1/9 0], 'DisplayName',users{it-1});
end

for it=1:size(data, 2)
    xEtiquetas{it}=['Image ' num2str(it)];
end

set(axes1,'FontSize',14,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14],...
    'XTickLabel', xEtiquetas, 'XTickLabelRotation',45);

ylabel(yLab);

if size(yAxisLims)==[1,2]
    ylim(axes1,yAxisLims)
end

if legendON
    legend1 = legend(axes1,'show');
    set(legend1,...
        'Position',[0.175 0.55 0.082680591818973 0.263908701854494]);
        %'Position',[0.73585726718886 0.629101283880172 0.082680591818973 0.263908701854494]);
end