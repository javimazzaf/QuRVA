addpath('/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/code/paperFigures/plotSpread/')

close all
% data = [randn(50,1);randn(50,1)+3.5]*[1 1];
% catIdx = [ones(50,1);zeros(50,1);randi([0,1],[100,1])];
% figure
% plotSpread(data,'categoryIdx',catIdx,...
%     'categoryMarkers',{'o','+'},'categoryColors',{[1 .5 .5],'b'})

axes1 = axes('Parent',gcf);

fakeData=diag(2500*ones(13,1));

bar(fakeData(1,:), 1, ...
    'FaceColor',[.80 .35 .35], 'EdgeColor', 'w')

hold on
for it=2:7
    bar(fakeData(it,:), 1, ...
        'FaceColor',[0 .2+1/it .0], 'EdgeColor', 'w')
end
for it=8:13
    bar(fakeData(it,:), 1, ...
        'FaceColor',[0 0 .2+1/(it-6)], 'EdgeColor', 'w')
end

xEtiquetas{1}='QuRVA';
for it=2:7
    xEtiquetas{it}=['User ' num2str(it-1)];
end
for it=8:13
    xEtiquetas{it}=['Swift ' num2str(it-6)];
end

set(axes1,'FontSize',14,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14],...
    'XTickLabel', xEtiquetas, 'XTickLabelRotation',45);


ylim(axes1,[0 2500])
% data=[FNpixelsVotosRel;FPpixelsVotosRel];
data=[FNrel'+FPrel'];

catIdx=repmat((1:13)', size(data,1), 1);


thisPlot=plotSpread(data,'categoryIdx',catIdx,...
    'categoryMarkers',{'o','o', 'o', 'o', 'o', 'o', 'o', 'o','o', 'o', 'o', 'o', 'o'},...
    'categoryColors',{'w','w','w','w','w','w','w', 'w','w','w','w','w','w'}, 'binWidth', 1)

hold off

ylabel('False pixels percentage');


