clear
%% Set folders
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/Anonymous/';
% Change folder if Javier
[~,user] = system('whoami');
if strcmp(strtrim(user),'javimazzaf'), masterFolder='../Anonymous/';end

warning('Off')
mkdir(masterFolder, 'Masks')
mkdir(masterFolder, 'TuftImages')
mkdir(masterFolder, 'TuftNumbers')
mkdir(masterFolder, 'VasculatureImages')
mkdir(masterFolder, 'VasculatureNumbers')

doTufts=1;
doVasculature=0;

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

    %% Check for a mask or make one
    if exist([masterFolder filesep 'Masks' filesep myFiles(it).name '.mat'],'file')
        load([masterFolder filesep 'Masks' filesep myFiles(it).name '.mat']);
    else
        thisMask=roipoly(thisImage);
        save([masterFolder filesep 'Masks' filesep myFiles(it).name '.mat'], 'thisMask');
    end
    
    %% Check for ON coordinates
    if exist([masterFolder filesep 'ONCenter' filesep myFiles(it).name '.mat'],'file')
        load([masterFolder filesep 'ONCenter' filesep myFiles(it).name '.mat']);
    end
    
    [maskStats, maskNoCenter]=processMask(thisMask, redImage, thisONCenter);
    
    %% Analyze tufts
    if doTufts==true

        [tuftsMask, brightMask, thickMask]=getTufts(thisMask, redImage, maskNoCenter);
               
    
        %% Get observers data
        [allMasks consensusMask]=getConsensusMask(it);

        %% Create votes Image
        votesImageRed=.5*redImage;
        votesImageGreen=.5*redImage;
        votesImageBlue=.5*redImage;

        myColors=prism;
        for ii=1:size(allMasks, 3)
            thisObserver=bwperim(allMasks(:,:,ii));
            votesImageRed(thisObserver~=0)=uint8(myColors(ii,1)*255);
            votesImageGreen(thisObserver~=0)=uint8(myColors(ii,2)*255);
            votesImageBlue(thisObserver~=0)=uint8(myColors(ii,3)*255);

        end
        votesImage=cat(3, votesImageRed, votesImageGreen, votesImageBlue);

        %% Save Tuft Images

        quadNW=cat(3, uint8(thickMask).*redImage, redImage, uint8(brightMask).*redImage);
        quadNE=cat(3, redImage, redImage, redImage);
        quadSW=cat(3, redImage, uint8(consensusMask)*255,uint8(consensusMask)*255);
        quadSE=votesImage;

        imwrite([quadNW quadNE; quadSW quadSE], ...
            [masterFolder filesep 'TuftImages' filesep myFiles(it).name], 'JPG')

        save([masterFolder filesep 'TuftNumbers' filesep myFiles(it).name '.mat'],...
            'tuftsMask', 'allMasks', 'consensusMask');
    
    end % do vasculature network
    
    if doVasculature==true

        [vesselSkelMask, brchPts]=getVacularNetwork(thisMask, redImage);
        [aVascZone]=getAvacularZone(thisMask, vesselSkelMask);

        %% Make a nice image
        leftHalf=cat(3, redImage, redImage, redImage);
        rightHalf=cat(3, redImage,...
            uint8(vesselSkelMask).*255,...
            uint8(logical(aVascZone)+imdilate(brchPts, strel('disk',3))).*255);
        
        imwrite([leftHalf rightHalf], ...
            [masterFolder filesep 'VasculatureImages' filesep myFiles(it).name], 'JPG')
             
        thisSholl=getShollEq(vesselSkelMask, maskStats, thisONCenter);
        
        save(fullfile(masterFolder, 'VasculatureNumbers', [myFiles(it).name,'.mat']),...
            'vesselSkelMask', 'brchPts','aVascZone', 'thisSholl');
    end
    

end

