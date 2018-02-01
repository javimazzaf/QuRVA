clear

masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/PaperImageSet/Anonymous/ValidationVasculature/';

myFiles = dir(fullfile(masterFolder,'*.tif'));
load([masterFolder, 'automatic.mat'], 'thisCount');



for it=67%1:numel(myFiles)
    redImage=imread(fullfile(masterFolder, myFiles(it).name));
    
    largeImage=imresize(redImage, [1000, 1000]);
    imshow(largeImage)
    hold on

    x=1;
    y=1;
    cellCounter=1;

    centersImage=zeros(size(largeImage));

    while x>=1 && x<max(size(largeImage, 2)) && y>=1 && y<max(size(largeImage, 1))
        [x, y]=ginput(1);
        cellCenters(cellCounter, 1)=x;
        cellCenters(cellCounter, 2)=y;
        cellCounter=cellCounter+1;

        plot(x, y, 'ro')
    end
    centerIndex=sub2ind(size(largeImage), round(cellCenters(1:end-1,2)), round(cellCenters(1:end-1,1)));
    
    myCounts(it)=numel(centerIndex);
    myLocations{it}=centerIndex;
    vars={'x', 'y', 'centerIndex', 'cellCenters'};
    clear(vars{:});
    
    save([masterFolder, 'SantiagoIII.mat'], 'myCounts', 'myLocations');
end

