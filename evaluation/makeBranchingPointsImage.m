masterFolder='/Users/javimazzaf/Dropbox (Biophotonics)/ValidationVasculature/';

load([masterFolder, 'automatic.mat'], 'thisCount','locations','skel');

load([masterFolder, 'santiago.mat'], 'myLocations');
santiagoLocs = myLocations;

load([masterFolder, 'javier.mat'], 'myLocations');
javierLocs = myLocations;

resDir = fullfile(masterFolder,'locationsImages');

if ~exist(resDir,'dir'), mkdir(resDir), end

myFiles = dir(fullfile(masterFolder,'*.tif'));

for it = 1:numel(myFiles)
    if isempty(santiagoLocs{it}) || isempty(javierLocs{it}) 
        continue
    end
    
    redImage = imread(fullfile(masterFolder, myFiles(it).name));
    
    fg = figure;
    imshow(imoverlay(redImage,skel{it},'y'),[],'Border','Tight'), hold on
    
    locs = santiagoLocs{it};
    [y,x] = ind2sub([1000 1000], locs);   
    x = x * 350 / 1000;
    y = y * 350 / 1000;
    plot(x,y,'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 1 0],'MarkerSize', 5)

    locs = javierLocs{it};
    [y,x] = ind2sub([1000 1000], locs);   
    x = x * 350 / 1000;
    y = y * 350 / 1000;
    plot(x,y,'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0.5 0],'MarkerSize', 5)  
    
    locs = locations{it};
    plot(locs(:,1),locs(:,2),'s','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize', 5)
    
    print(fg,fullfile(resDir,[myFiles(it).name(1:end-3) 'png']), '-dpng')
    
    close(fg)
    
end
