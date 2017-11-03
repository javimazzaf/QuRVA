clear

% loads local parameters
readConfig;

mkdir(masterFolder, 'Global')

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

    
    %% Create votes Image
    votesImageRed=.5*redImage;
    votesImageGreen=.5*redImage;
    votesImageBlue=.5*redImage;

    falseImageRed=.5*redImage;
    falseImageGreen=.5*redImage;
    falseImageBlue=.5*redImage;
    
    myColors=prism;
    
    for ii=1:size(allMasks, 3)
        thisObserver=bwperim(allMasks(:,:,ii));
        votesImageRed(thisObserver~=0)=uint8(myColors(ii,1)*255);
        votesImageGreen(thisObserver~=0)=uint8(myColors(ii,2)*255);
        votesImageBlue(thisObserver~=0)=uint8(myColors(ii,3)*255);

    end
    
    for ii=1:size(allMasks, 3)
        thisObserver=double(allMasks(:,:,ii));
        falseImageRed(thisObserver-consensusMask~=0)=uint8(myColors(ii,1)*255);
        falseImageRed(consensusMask~=0)=uint8(255);
        falseImageGreen(thisObserver-consensusMask~=0)=uint8(myColors(ii,2)*255);
        falseImageGreen(consensusMask~=0)=uint8(255);
        falseImageBlue(thisObserver-consensusMask~=0)=uint8(myColors(ii,3)*255);
        falseImageBlue(consensusMask~=0)=uint8(255);
    end
    
    izq=cat(3, redImage, redImage, redImage).*uint8(thisMask);
    der=cat(3, falseImageRed, falseImageGreen, falseImageBlue).*uint8(thisMask);
    

    thisMaskStats=regionprops('table', thisMask, 'boundingBox');
    izq=imcrop(izq, thisMaskStats.BoundingBox(1,:));
    der=imcrop(der, thisMaskStats.BoundingBox(1,:));
    
    imshow([izq der])

end