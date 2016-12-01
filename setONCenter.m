clear
%% Set folders
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/Anonymous/';
warning('Off')
mkdir(masterFolder, 'ONCenter')

%% Get file names
myFiles=dir([masterFolder filesep '*.jpg']);
if numel(myFiles)==0
    myFiles=dir([masterFolder filesep '*.tif']);
end

%% Do loop
for it=1:numel(myFiles)
    myFiles(it).name
    
    %% Read image
    thisImage=imread([masterFolder filesep myFiles(it).name]);
    redImage=thisImage(:,:,1);
    
        %% Make 8 bits
    if strcmp(class(redImage), 'uint16')
        redImage=uint8(double(redImage)/65535*255);
    end

    %% get Coordinates
    imshow(cat(3, zeros(size(redImage)),redImage,zeros(size(redImage))))
    [x,y]=ginput(1);
    thisONCenter=[round(x) round(y)];
    save([masterFolder 'ONCenter' filesep myFiles(it).name '.mat'], 'thisONCenter');
end