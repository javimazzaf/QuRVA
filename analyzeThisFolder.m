 function analyzeThisFolder

readConfig;

warning('Off')
mkdir(masterFolder, 'Masks')
mkdir(masterFolder, 'TuftImages')
mkdir(masterFolder, 'TuftNumbers')
mkdir(masterFolder, 'VasculatureImages')
mkdir(masterFolder, 'VasculatureNumbers')

myFiles = getImageList(masterFolder);

%% Prepare mask and Center
computeMaskAndCenter(masterFolder, myFiles);

%% Do loop
for it=1:14
    
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
        
    if doVasculature
        
        [vesselSkelMask, brchPts, smoothVessels]=getVacularNetwork(thisMask, redImage);
        [aVascZone]=getAvacularZone2(thisMask, vesselSkelMask, smoothVessels);
        [aVascAllMasks aVascConsensus]=getAVascularConsensusMask(it);
        
        if doSaveImages
            %% Make a nice image
            leftHalf=cat(3, redImage, uint8(imdilate(bwperim(aVascConsensus),strel('disk',4)))*255, uint8(imdilate(bwperim(aVascZone),strel('disk',4)))*255);
            rightHalf=cat(3, redImage,...
                uint8(vesselSkelMask).*255,...
                uint8(imdilate(bwperim(aVascZone), strel('disk', 5)) +imdilate(brchPts, strel('disk',3))).*255);
            
            leftHalf=imcrop(leftHalf, maskStats.BoundingBox);
            rightHalf=imcrop(rightHalf, maskStats.BoundingBox);
            
            imwrite([leftHalf rightHalf], fullfile(masterFolder,'VasculatureImages',myFiles{it}), 'JPG')
        end % doSaveImages
        
%         thisSholl=getShollEq(vesselSkelMask, maskStats, thisONCenter);
        
        save(fullfile(masterFolder, 'VasculatureNumbers', [myFiles{it},'.mat']),...
            'vesselSkelMask', 'brchPts','aVascZone');
    end % doVasculature
    
    %% Analyze tufts
    if doTufts
        
        if exist('smoothVessels', 'var')
            %[tuftsMask, thickMask]=getTufts(thisMask, redImage, maskNoCenter, smoothVessels);
            tuftsMask=getTuftsConvNet(thisMask, redImage, maskNoCenter, smoothVessels);
            %tuftsMask = getTuftQC(redImage, thisMask, maskNoCenter, tuftsMask);

        else
            %[tuftsMask, thickMask]=getTufts(thisMask, redImage, maskNoCenter);
            tuftsMask=testSURF(redImage, maskNoCenter, thisMask);
        end
        
        %% Get observers data
        load(fullfile(masterFolder,'TuftConsensusMasks',[myFiles{it} '.mat']),'allMasks','consensusMask','orMask')
        
        % Modify evaluation by replacing the consensus by the orMask.
        % consensusMask = orMask;
        
        if doSaveImages
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
            
            quadNW=cat(3, redImage, uint8(~tuftsMask).*redImage, uint8(~tuftsMask).*redImage);
            quadNE=cat(3, redImage, redImage, redImage);
            quadSW=imoverlay(imoverlay(imoverlay(redImage, uint8(tuftsMask-consensusMask>0)*255, 'm'), uint8(tuftsMask-consensusMask<0)*255, 'y'), uint8(and(consensusMask, tuftsMask))*255, 'g');
            quadSE=votesImage;
            
            imwrite([quadNW quadNE; quadSW quadSE], fullfile(masterFolder, 'TuftImages', myFiles{it}), 'JPG')
            
        end % doSaveImages
        
        save(fullfile(masterFolder,'TuftNumbers',[myFiles{it} '.mat']),'tuftsMask', 'allMasks', 'consensusMask');
        
    end % doTufts
    
    
end

