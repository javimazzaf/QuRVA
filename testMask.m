readConfig

myFiles = getImageList(masterFolder);

% myFiles = cellfun(@(x) x(1:end-4),myFiles,'UniformOutput',false);

for k = 15:numel(myFiles)
    load(fullfile(masterFolder,'Masks', [myFiles{k} '.mat']), 'thisMask')
    load(fullfile(masterFolder,'ONCenter', [myFiles{k} '.mat']))
    
    im = imread(fullfile(masterFolder,myFiles{k}));
    
    imshow(imoverlay(mat2gray(im),bwperim(thisMask),'m')), hold on
    plot(thisONCenter(1),thisONCenter(2),'*r');
    title(myFiles{k})
    hold off
    
    pause(1)
    
end