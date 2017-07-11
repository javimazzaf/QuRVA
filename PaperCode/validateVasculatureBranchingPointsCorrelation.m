masterFolder='/Users/javimazzaf/Dropbox (Biophotonics)/ValidationVasculature/';

load([masterFolder, 'automatic.mat'], 'thisCount');
counts = thisCount.QuRVA(:);

counts = [counts,zeros(size(counts)),zeros(size(counts))];

load([masterFolder, 'santiago.mat'], 'myCounts');
counts(1:length(myCounts),2) = myCounts';

load([masterFolder, 'SantiagoII.mat'], 'myCounts');
counts(1:length(myCounts),2) = counts(1:length(myCounts),2) + myCounts';

load([masterFolder, 'SantiagoIII.mat'], 'myCounts');
counts(1:length(myCounts),2) = counts(1:length(myCounts),2) + myCounts';

load([masterFolder, 'javier.mat'], 'myCounts');
counts(1:length(myCounts),3) = myCounts';

mskGood = any(counts(:,[2,3])' >= 10)';

counts = counts(mskGood,:);

corrSet = [[counts(:,1);counts(:,1)], [counts(:,2);counts(:,3)]];
mskGood = corrSet(:,2) >= 10;

corrSet = corrSet(mskGood,:);

[r,p] = corr(corrSet(:,1),corrSet(:,2),'type','pearson');

fg = figure;
plot(counts(counts(:,2) > 10,1),counts(counts(:,2) > 10,2),'o','MarkerEdgeColor',[0 1 0],'MarkerFaceColor',[0 1 0]), hold on
plot(counts(counts(:,3) > 10,1),counts(counts(:,3) > 10,3),'o','MarkerEdgeColor',[0 0.5 0],'MarkerFaceColor',[0 0.5 0])
set(gca,'FontSize',16)
legend({'User 1';'User 2'},'Location','NorthWest')
xlabel('QuRVA number of branch points')
ylabel('Number of branch points (manual)')
set(gca,'FontSize',16)
if p < 0.001
   strText = ['R = ' num2str(r,'%0.2f') 10 '(p < 0.001)'];
else
   strText = ['R = ' num2str(r,'%0.2f') 10 '(p = ' num2str(p) ')'];
end

% Draw fit line
[fo, gof] = fit(corrSet(:,1),corrSet(:,2),'poly1');
plot(corrSet(:,1),fo(corrSet(:,1)),'-r','LineWidth',2)

text(350,25,strText,'FontSize',16)
% print(fg,fullfile(masterFolder, 'correl.pdf'),'-dpdf')