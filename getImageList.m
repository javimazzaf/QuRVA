function myFiles = getImageList(masterFolder)

myFiles = dir(fullfile(masterFolder, '*.jpg'));
myFiles = [myFiles; dir(fullfile(masterFolder, '*.tif'))];
myFiles = {myFiles(:).name};

end