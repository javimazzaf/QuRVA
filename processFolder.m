clear

%% Settings and folders
if exist('localConfig.m','file')
    localConfig
else
    masterFolder=uigetdir('/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/', 'Select folder')
end

warning('Off')
mkdir(masterFolder, 'Masks')
mkdir(masterFolder, 'TuftImages')
mkdir(masterFolder, 'TuftNumbers')
mkdir(masterFolder, 'VasculatureImages')
mkdir(masterFolder, 'VasculatureNumbers')
mkdir(masterFolder, 'ONCenter')

doTufts=1;
doVasculature=1;

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
    
    if exist('fg','var'), close(fg); clear fg; end
    
    [maskStats, maskNoCenter]=processMask(thisMask, redImage, thisONCenter);
    
    
    if doVasculature==true

        [vesselSkelMask, brchPts, smoothVessels]=getVacularNetwork(thisMask, redImage);
        [aVascZone]=getAvacularZone(thisMask, vesselSkelMask);

        %% Make a nice image
        leftHalf=cat(3, redImage, redImage, uint8(smoothVessels)*255);
        rightHalf=cat(3, redImage,...
            uint8(vesselSkelMask).*255,...
            uint8(logical(aVascZone)+imdilate(brchPts, strel('disk',5))).*255);
        
        imwrite([leftHalf rightHalf], ...
            [masterFolder filesep 'VasculatureImages' filesep myFiles(it).name], 'JPG')
             
        thisSholl=getShollEq(vesselSkelMask, maskStats, thisONCenter);
        
        save(fullfile(masterFolder, 'VasculatureNumbers', [myFiles(it).name,'.mat']),...
            'vesselSkelMask', 'brchPts','aVascZone', 'thisSholl');
    end

    %% Analyze tufts
    if doTufts==true

        if exist('smoothVessels', 'var')
            [tuftsMask, brightMask, thickMask]=getTufts(thisMask, redImage, maskNoCenter, smoothVessels);
        else
            [tuftsMask, brightMask, thickMask]=getTufts(thisMask, redImage, maskNoCenter);
        end
               


        %% Save Tuft Images

        quadNW=cat(3, uint8(thickMask).*redImage, redImage, uint8(brightMask).*redImage);
        quadNE=cat(3, redImage, redImage, redImage);

        imwrite([quadNW quadNE], ...
            [masterFolder filesep 'TuftImages' filesep myFiles(it).name], 'JPG')

        save([masterFolder filesep 'TuftNumbers' filesep myFiles(it).name '.mat'],...
            'tuftsMask');
    
    end % do vasculature network
    
    
end

