clear

% loads local parameters
readConfig;


%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

myImageFiles=dir(fullfile(masterFolder,'*.jpg'));
myImageFiles = {myImageFiles(:).name};


distancesStats = num2cell(zeros(1,13));

%% Load results

for it=1:14
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask','allMasks','orMask');
    load(fullfile(masterFolder, 'Masks', myFiles{it}),'thisMask');

    
    redImage=imread(fullfile(masterFolder, myImageFiles{it}));
    
    gridImage=zeros(size(redImage));
    for row=1:16:size(gridImage, 1)
        for col=1:16:size(gridImage, 2)
            gridImage(:, col)=1;
            gridImage(row, :)=1;
        end
    end
    
    im2show=cat(3, redImage+uint8(gridImage)*255, gridImage*255, (consensusMask+gridImage)*255);
    
   

    thisMaskStats=regionprops('table', thisMask, 'boundingBox');
    im2show=imcrop(im2show, thisMaskStats.BoundingBox(1,:));

    
    imshow(im2show)

end