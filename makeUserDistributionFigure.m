function makeUserDistributionFigure(data, ylab, legendFlag, ixSort)

axes1 = axes('Parent',gcf);

% Sorting according to majority

if ~exist('ixSort','var')
    [~, ix] = sort(data');
    
    for k = 1:max(ix(:))
        [aux, ~] = find(ix == k);
        ord(k) = mean(aux);
    end
    
    [~,ixSort] = sort(ord);   
end

data = data(:,ixSort);

it = 1;
bars = bar(it + ((1:size(data,2)) - floor(size(data,2)/2)) / size(data,2) * 0.5  , data(it,:));
set(bars,'FaceColor',[1 0 0],'EdgeColor',[1 0 0]);
hold on

meds(it) = nanmedian(data(it,:));

xlabels = {'QuRVA'};

for it=2:7
    xlabels = [xlabels;['User ' num2str(it-1)]];
    bars = bar(it + ((1:size(data,2)) - floor(size(data,2)/2)) / size(data,2) * 0.5  , data(it,:));
    clr = [0 it/ceil(size(data,2)/2) 0];
    set(bars,'FaceColor',clr,'EdgeColor',clr);
    
    meds(it) = nanmedian(data(it,:));
    
    plot(it + ((1:size(data,2)) - floor(size(data,2)/2)) / size(data,2) * 0.5, meds(it) * ones(size(data(it,:))), 'Color', 'k','linewidth',1)
    
    x = it + 0.5/size(data,2) - [1 0.5] * floor(size(data,2)/2) / size(data,2);
    y = meds(it) * [1 1];
    
    ah=annotation('arrow');
    set(ah,'parent',gca);
    set(ah,'position',[x(1), y(1), range(x), range(y)],'HeadStyle','plain');
    
end

for it = 8:size(data, 1)
    xlabels = [xlabels;['Swift ' num2str(it-7)]];
    bars = bar(it + ((1:size(data,2)) - floor(size(data,2)/2)) / size(data,2) * 0.5  , data(it,:));
    clr = [.6, .1, (it-7)/ceil(size(data,2)/2)];
    set(bars,'FaceColor',clr,'EdgeColor',clr);
    
    meds(it) = nanmedian(data(it,:));
    
    plot(it + ((1:size(data,2)) - floor(size(data,2)/2)) / size(data,2) * 0.5, meds(it) * ones(size(data(it,:))), 'Color', 'k','linewidth',1)  
    
    x = it + 0.5/size(data,2) - [1 0.5] * floor(size(data,2)/2) / size(data,2);
    y = meds(it) * [1 1];
    
    ah = annotation('arrow');
    set(ah,'parent',gca);
    set(ah,'position',[x(1), y(1), range(x), range(y)],'HeadStyle','plain');    
    
end

plot(xlim(), meds(1) * [1 1], '--r','linewidth',1)
plot(1 + ((1:size(data,2)) - floor(size(data,2)/2)) / size(data,2) * 0.5, meds(1) * ones(size(data(it,:))), 'Color', 'k','linewidth',1)
x = 1 + 0.5/size(data,2) - [1 0.5] * floor(size(data,2)/2) / size(data,2);
y = meds(1) * [1 1];

ah=annotation('arrow');
set(ah,'parent',gca);
set(ah,'position',[x(1), y(1), range(x), range(y)],'HeadStyle','plain');

set(axes1,'linewidth',2,'FontSize',16,'XTick',1:size(data, 1),...
    'XTickLabel', xlabels, 'XTickLabelRotation',45);

ylabel(ylab);