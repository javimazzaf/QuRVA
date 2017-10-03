function processFolder(varargin)

try
    %% Settings and folders
    readConfig
    
    if nargin>0
        masterFolder=varargin{1};
    else
        masterFolder = uigetdir('', 'Select folder');
    end
    
    warning('Off')
    mkdir(masterFolder, 'Masks')
    mkdir(masterFolder, 'TuftImages')
    mkdir(masterFolder, 'TuftNumbers')
    mkdir(masterFolder, 'VasculatureImages')
    mkdir(masterFolder, 'VasculatureNumbers')
    mkdir(masterFolder, 'ONCenter')
    mkdir(masterFolder, 'Reports')
    warning('On')
    
    if nargin > 1
        myFiles = varargin{2};
    else
        myFiles = getImageList(masterFolder);
    end
    
    load('model.mat','model')
    
    %% Prepare mask and Center
    computeMaskAndCenter(masterFolder, myFiles,computeMaskAndCenterAutomatically);
    
    %% Do loop
    for it=1:numel(myFiles)
        try
            %% Verbose current Image
            disp(['Processing: ' myFiles{it}])
            
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
            
            [redImage, scaleFactor] = resetScale(redImage);
            thisMask     = resetScale(thisMask);
            maskNoCenter = resetScale(maskNoCenter);
            thisONCenter = thisONCenter/scaleFactor;
            retinaDiam   = computeRetinaSize(thisMask, thisONCenter);
            
            if doVasculature
                
                disp('  Computing vasculature . . .')
                [vesselSkelMask, brchPts, smoothVessels, endPts] = getVacularNetwork(thisMask, redImage);
                aVascZone = getAvacularZone(thisMask, vesselSkelMask, retinaDiam, thisONCenter);
                
                %% Make a nice image
                if doSaveImages
                    
                    leftHalf=cat(3, redImage, redImage, redImage);
                    rightHalf=makeNiceVascularImage(redImage, aVascZone, vesselSkelMask, brchPts);
                    
                    leftHalf=imcrop(leftHalf, maskStats.BoundingBox/scaleFactor);
                    rightHalf=imcrop(rightHalf, maskStats.BoundingBox/scaleFactor);
                    
                    imwrite([leftHalf rightHalf], fullfile(masterFolder, 'VasculatureImages', myFiles{it}), 'JPG')
                    
                end % doSaveImages
                
                save(fullfile(masterFolder, 'VasculatureNumbers', [myFiles{it},'.mat']),...
                    'vesselSkelMask', 'brchPts', 'aVascZone', 'endPts','smoothVessels');
                
                disp('  Vasculature done.')
                
            end % doVasculature
            
            %% Analyze tufts
            if doTufts
                
                disp('  Computing tufts . . .')
                
                tuftsMask = getTufts(redImage, maskNoCenter, thisMask, thisONCenter, retinaDiam, model);
                
                %% Save Tuft Images
                if doSaveImages
      
                    adjustedImage = overSaturate(redImage);
                    
                    quadNW = imcrop(cat(3, uint8(tuftsMask) .* adjustedImage,adjustedImage, adjustedImage), maskStats.BoundingBox/scaleFactor);
                    quadNE = imcrop(cat(3, adjustedImage, adjustedImage, adjustedImage), maskStats.BoundingBox/scaleFactor);
                    
                    imwrite([quadNW quadNE], fullfile(masterFolder, 'TuftImages', myFiles{it}), 'JPG')
                end
                
                save(fullfile(masterFolder, 'TuftNumbers', [myFiles{it} '.mat']), 'tuftsMask');
                
                disp('  Tufts done.')
                
            end % doTufts
            
            outFlatMountArea(it)     = sum(thisMask(:));
            outBranchingPoints(it)   = sum(brchPts(:));
            outAVascularArea(it)     = sum(aVascZone(:));
            outVasculatureLength(it) = sum(vesselSkelMask(:));
            outTuftArea(it)          = sum(tuftsMask(:));
            outTuftNumber(it)        = max(max(bwlabel(tuftsMask)));
            outEndPoints(it)         = sum(endPts(:));
            
            disp(['Done: ' myFiles{it}])
            
        catch loopException
            disp(['Error in processFolder(image ' myFiles{it} '). Message: ' loopException.message buildCallStack(loopException)]);
            continue
        end
        
    end
    
    resultsTable                   = table;
    resultsTable.FileName          = myFiles';
    resultsTable.FlatMountArea     = outFlatMountArea';
    resultsTable.BranchingPoints   = outBranchingPoints';
    resultsTable.AVascularArea     = outAVascularArea';
    resultsTable.VasculatureLength = outVasculatureLength';
    resultsTable.TuftArea          = outTuftArea';
    resultsTable.TuftNumber        = outTuftNumber';
    resultsTable.EndPoints         = outEndPoints';
    
    tableFileName = fullfile(masterFolder, 'Reports', 'AnalysisResult.xlsx');
    
    oldTable = [];
    if exist(tableFileName,'file')
        oldTable = readtable(tableFileName);
    end
    
    writetable([oldTable;resultsTable],tableFileName)
    
catch globalException
    disp(['Error in processFolder. Message: ' globalException.message buildCallStack(globalException)]);
end

end

