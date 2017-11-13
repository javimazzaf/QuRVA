% *************************************************************************
% Parameters (optional): If not included it uses the default behaviour
% varargin{1} = masterFolder (string with folder path) default: config.ini
% varargin{2} = myFiles (particular file names in a cellarray): default: files in master folder
% varargin{3} = model (object containint QDA object): default model.mat in current folder
% varargin{3} = doConsensusImages : default false
% *************************************************************************

function processFolder(varargin)

try
    %% Settings and folders
    readConfig
    
    if nargin > 0, masterFolder=varargin{1};
    else,          masterFolder = uigetdir('', 'Select folder'); end
    
    if nargin > 1, myFiles = varargin{2}; 
    else,          myFiles = getImageList(masterFolder); end
    
    if nargin > 2, model = varargin{3};
    else,          load('model.mat','model'); end
    
    if nargin > 3, doConsensusImages = varargin{4};
    else,          doConsensusImages = false; end
    
    warning('Off')
    mkdir(masterFolder, 'Masks')
    mkdir(masterFolder, 'TuftImages')
    mkdir(masterFolder, 'TuftNumbers')
    mkdir(masterFolder, 'VasculatureImages')
    mkdir(masterFolder, 'VasculatureNumbers')
    mkdir(masterFolder, 'ONCenter')
    mkdir(masterFolder, 'Reports')
    warning('On')
    
    %% Prepare mask and Center
    computeMaskAndCenter(masterFolder, myFiles,computeMaskAndCenterAutomatically);
    
    myFiles = myFiles(:);
    
    outFlatMountArea     = zeros(size(myFiles));
    outBranchingPoints   = outFlatMountArea;
    outAVascularArea     = outFlatMountArea;
    outVasculatureLength = outFlatMountArea;
    outTuftArea          = outFlatMountArea;
    outTuftNumber        = outFlatMountArea;
    outEndPoints         = outFlatMountArea;
    
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
            
            % For Results
            outFlatMountArea(it)     = sum(thisMask(:));
            
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
                
                % For Results
                outBranchingPoints(it)   = sum(brchPts(:));
                outAVascularArea(it)     = sum(aVascZone(:));
                outVasculatureLength(it) = sum(vesselSkelMask(:));
                outEndPoints(it)         = sum(endPts(:));
                
            end % doVasculature
            
            %% Analyze tufts
            if doTufts
                
                disp('  Computing tufts . . .')
                
                tuftsMask = getTufts(redImage, maskNoCenter, thisMask, thisONCenter, retinaDiam, model);
                %                 tuftsMask = getTufts(overSaturate(redImage), maskNoCenter, thisMask, thisONCenter, retinaDiam, model);
                
                % *** Save Tuft Images ***
                if doSaveImages
                    
                    adjustedImage = uint8(overSaturate(redImage) * 255);
                    cropRect      = maskStats.BoundingBox/scaleFactor;
                    
                    % Build image top quadrants
                    quadNW = cat(3, uint8(tuftsMask) .* adjustedImage,adjustedImage, adjustedImage);
                    quadNE = cat(3, adjustedImage, adjustedImage, adjustedImage);
                    
                    quadNW = imoverlay(quadNW,imdilate(bwperim(thisMask & maskNoCenter),strel('disk',3)),'m');
                    
                    quadNW = imcrop(quadNW, cropRect);
                    quadNE = imcrop(quadNE, cropRect);
                    
                    resultImage = [quadNW quadNE];
                    
                    % Add consensus panel
                    if doConsensusImages
                        
                        % Create Image for all voters
                        load(fullfile(masterFolder,'TuftConsensusMasks',[myFiles{it} '.mat']),'allMasks')
                        consensusMask = sum(allMasks, 3) >= consensus.reqVotes;
                        
                        votesImageRed   = 0.5 * adjustedImage;
                        votesImageGreen = 0.5 * adjustedImage;
                        votesImageBlue  = 0.5 * adjustedImage;
                        
                        myColors = prism;
                        
                        for ii=1:size(allMasks, 3)
                            thisMask = resetScale(allMasks(:,:,ii));
                            thisObserver = bwperim(thisMask);
                            votesImageRed(  thisObserver~=0) = uint8(myColors(ii,1) * 255);
                            votesImageGreen(thisObserver~=0) = uint8(myColors(ii,2) * 255);
                            votesImageBlue( thisObserver~=0) = uint8(myColors(ii,3) * 255);
                        end
                        
                        consensusMask = resetScale(consensusMask);
                        
                        % Build image bottom quadrants
                        quadSW = imoverlay(imoverlay(imoverlay(adjustedImage, uint8(tuftsMask-consensusMask>0)*255, 'm'), uint8(tuftsMask-consensusMask<0)*255, 'y'), uint8(and(consensusMask, tuftsMask))*255, 'g');
                        quadSE = cat(3, resetScale(votesImageRed), resetScale(votesImageGreen), resetScale(votesImageBlue));
                        
                        % Crop bottom quadrants
                        quadSW = imcrop(quadSW, cropRect);
                        quadSE = imcrop(quadSE, cropRect);
                        
                        resultImage = [resultImage; quadSW quadSE];
                        
                    end
                    
                    % Save image
                    imwrite(resultImage, fullfile(masterFolder, 'TuftImages', myFiles{it}), 'JPG')
                    
                end
                
                save(fullfile(masterFolder, 'TuftNumbers', [myFiles{it} '.mat']), 'tuftsMask');
                
                % For Results
                outTuftArea(it)          = sum(tuftsMask(:));
                outTuftNumber(it)        = max(max(bwlabel(tuftsMask)));
                
                disp('  Tufts done.')
                
            end % doTufts
            
            disp(['Done: ' myFiles{it}])
            
        catch loopException
            disp(['Error in processFolder(image ' myFiles{it} '). Message: ' loopException.message buildCallStack(loopException)]);
            continue
        end
        
    end
    
    resultsTable                   = table;
    resultsTable.FileName          = myFiles;
    resultsTable.FlatMountArea     = outFlatMountArea;
    resultsTable.BranchingPoints   = outBranchingPoints;
    resultsTable.AVascularArea     = outAVascularArea;
    resultsTable.VasculatureLength = outVasculatureLength;
    resultsTable.TuftArea          = outTuftArea;
    resultsTable.TuftNumber        = outTuftNumber;
    resultsTable.EndPoints         = outEndPoints;
    
    add2Table(masterFolder,resultsTable);
    
catch globalException
    disp(['Error in processFolder. Message: ' globalException.message buildCallStack(globalException)]);
end

end



