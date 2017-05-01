function processFolder
%% Settings and folders
readConfig
if ~exist('masterFolder','var')
    masterFolder = uigetdir('/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/', 'Select folder');
end

warning('Off')
mkdir(masterFolder, 'Masks')
mkdir(masterFolder, 'TuftImages')
mkdir(masterFolder, 'TuftNumbers')
mkdir(masterFolder, 'VasculatureImages')
mkdir(masterFolder, 'VasculatureNumbers')
mkdir(masterFolder, 'ONCenter')

myFiles = getImageList(masterFolder);

%% Prepare mask and Center
computeMaskAndCenter(masterFolder, myFiles);

%% Do loop
for it=1:14 %numel(myFiles)
    
    %% Verbose current Image
    disp(myFiles{it})
    
    %% Read image
    thisImage=imread(fullfile(masterFolder, myFiles{it}));
    redImage=thisImage(:,:,1);
    
    %% Make 8 bits
    if strcmp(class(redImage), 'uint16')
        redImage=uint8(double(redImage)/65535*255);
    end
    
    %% Load Mask and Center
    load(fullfile(masterFolder, 'Masks',    [myFiles{it} '.mat']), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', [myFiles{it} '.mat']), 'thisONCenter');
    
    [maskStats, maskNoCenter] = processMask(thisMask, redImage, thisONCenter);
    
    if doVasculature==true
        
        [vesselSkelMask, brchPts, smoothVessels]=getVacularNetwork(thisMask, redImage);
        [aVascZone]=getAvacularZone(thisMask, vesselSkelMask);
        
        %% Make a nice image
        if doSaveImages
            
            leftHalf=cat(3, redImage, redImage, uint8(smoothVessels)*255);
            rightHalf=cat(3, redImage,...
                uint8(vesselSkelMask).*255,...
                uint8(logical(aVascZone)+imdilate(brchPts, strel('disk',5))).*255);
            
            imwrite([leftHalf rightHalf], fullfile(masterFolder, 'VasculatureImages', myFiles{it}), 'JPG')
            
        end % doSaveImages
        
        thisSholl = getShollEq(vesselSkelMask, maskStats, thisONCenter);
        
        save(fullfile(masterFolder, 'VasculatureNumbers', [myFiles{it},'.mat']),...
            'vesselSkelMask', 'brchPts', 'aVascZone', 'thisSholl');
    end % doVasculature
    
    %% Analyze tufts
    if doTufts==true
        
        if exist('smoothVessels', 'var')
            [tuftsMask, thickMask]=getTufts(thisMask, redImage, maskNoCenter, smoothVessels);
        else
            [tuftsMask, thickMask]=getTufts(thisMask, redImage, maskNoCenter);
        end
        
        %% Save Tuft Images
        if doSaveImages
            
            quadNW=cat(3, uint8(tuftsMask).*redImage, redImage, redImage);
            quadNE=cat(3, redImage, redImage, redImage);
            
            imwrite([quadNW quadNE], fullfile(masterFolder, 'TuftImages', myFiles{it}), 'JPG')
            
        end % doSaveImages
        
        save(fullfile(masterFolder, 'TuftNumbers', [myFiles{it} '.mat']), 'tuftsMask');
        
    end % doTufts
    
    
end

end

