clear
%% Set folders
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/PaperImageSet/Anonymous/';

% loads local parameters
if exist('localConfig.m','file'), localConfig; end

warning('Off')
mkdir(masterFolder, 'Masks')
mkdir(masterFolder, 'TuftImages')
mkdir(masterFolder, 'TuftNumbers')
mkdir(masterFolder, 'VasculatureImages')
mkdir(masterFolder, 'VasculatureNumbers')

doTufts=1;
doVasculature=0;

%% Get file names
myFiles=dir(fullfile(masterFolder, '*.jpg'));
if isempty(myFiles)
    myFiles=dir(fullfile(masterFolder, '*.tif'));
end

%% Do loop
for it=1:numel(myFiles)
    disp(myFiles(it).name)
    
    %% Read image
    thisImage=imread(fullfile(masterFolder, myFiles(it).name));
    redImage=thisImage(:,:,1);
    
    %% Make 8 bits
    if strcmp(class(redImage), 'uint16')
        redImage=uint8(double(redImage)/65535*255);
    end

    %% Load mask and center
    maskFile = fullfile(masterFolder, 'Masks', [myFiles(it).name '.mat']);
    if exist(maskFile,'file')
        load(maskFile,'thisMask');  
    else
        thisMask=getMask(redImage);
        fg = figure;
        imshow(imoverlay(redImage,imdilate(bwperim(thisMask),strel('disk',5)),'m'))
        
        while true
            
            if strcmp(questdlg('Are you happy with the mask?', 'Yes', 'No'),'No')
                imshow(redImage,[])
                thisMask=roipoly(thisImage);
                imshow(imoverlay(redImage,imdilate(bwperim(thisMask),strel('disk',5)),'m'))
            else
                save(maskFile, 'thisMask');
                break
            end
        end
        
    end
    
    centerFile = fullfile(masterFolder, 'ONCenter', [myFiles(it).name '.mat']);
    if exist(centerFile,'file')
        load(centerFile,'thisONCenter');
    else
        while true
            
            if exist('fg','var'), clf(fg)
            else                , fg = figure; end
            
            imshow(redImage,[]), hold on
            title('Set center')
            [x,y]=ginput(1);
            thisONCenter=round([x y]);
            plot(x,y,'*g')
            
            if strcmp(questdlg('Are you happy with the Center?', 'Yes', 'No'),'Yes')
                save(centerFile, 'thisONCenter');
                break
            end
            
        end
        
    end
    
    if exist('fg','var'), close(fg), end
    
    [maskStats, maskNoCenter]=processMask(thisMask, redImage, thisONCenter);
    
    %% Analyze tufts
    if doTufts==true

        [tuftsMask, brightMask, thickMask]=getTufts(thisMask, redImage, maskNoCenter);
               
        %% Get observers data
        [allMasks, consensusMask]=getTuftConsensusMask(myFiles(it).name);

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
        [aVascAllMasks aVascConsensus]=getAVascularConsensusMask(it);

        %% Make a nice image
        leftHalf=cat(3, redImage, redImage, uint8(aVascConsensus)*255);
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

