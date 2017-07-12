function processFolder(varargin)
%% Settings and folders
readConfig


    masterFolder = uigetdir('/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/', 'Select folder');

warning('Off') 
mkdir(masterFolder, 'Masks')
mkdir(masterFolder, 'TuftImages')
mkdir(masterFolder, 'TuftNumbers')
mkdir(masterFolder, 'VasculatureImages')
mkdir(masterFolder, 'VasculatureNumbers')
mkdir(masterFolder, 'ONCenter')
mkdir(masterFolder, 'Reports')

myFiles = getImageList(masterFolder);

load('model.mat','model')

%% Prepare mask and Center
computeMaskAndCenter(masterFolder, myFiles);

%% Do loop
for it=1:numel(myFiles)
    
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
    
    [redImage, scaleFactor]=resetScale(redImage);
        thisMask=resetScale(thisMask);
        maskNoCenter=resetScale(maskNoCenter);
        thisONCenter=thisONCenter/scaleFactor;
        retinaDiam = computeRetinaSize(thisMask, thisONCenter);
    
    if doVasculature==true
        
        [vesselSkelMask, brchPts, smoothVessels, endPts]=getVacularNetwork(thisMask, redImage);
        [aVascZone]=getAvacularZone(thisMask, vesselSkelMask);
        
        %% Make a nice image
        if doSaveImages
            
            leftHalf=cat(3, redImage, redImage, redImage);
            rightHalf=makeNiceVascularImage(redImage, aVascZone, vesselSkelMask, brchPts);
            
            leftHalf=imcrop(leftHalf, maskStats.BoundingBox/scaleFactor);
            rightHalf=imcrop(rightHalf, maskStats.BoundingBox/scaleFactor);
            
            imwrite([leftHalf rightHalf], fullfile(masterFolder, 'VasculatureImages', myFiles{it}), 'JPG')
            
        end % doSaveImages
        
        %thisSholl = getShollEq(vesselSkelMask, maskStats, thisONCenter);
        
        save(fullfile(masterFolder, 'VasculatureNumbers', [myFiles{it},'.mat']),...
            'vesselSkelMask', 'brchPts', 'aVascZone', 'endPts');
    end % doVasculature
    
    %% Analyze tufts
    if doTufts==true
        
        

        blockSize = ceil(retinaDiam * tufts.blockSizeFraction) * [1 1];
 
        
        [blocks, indBlocks] = getBlocks(redImage, blockSize, [0 0]);

        candidateBlocks  = getBlocksInMask(indBlocks, maskNoCenter & thisMask, tufts.blocksInMaskPercentage, [0 0]);

        blockFeatures = computeBlockFeatures(redImage, maskNoCenter, thisMask, indBlocks, candidateBlocks,[],[0 0],thisONCenter);

       
        y = predict(model, blockFeatures);
       
        goodBlocks = candidateBlocks(y > 0.5,:);

        tuftsMask = blocksToMask(size(redImage), indBlocks, goodBlocks, [0 0]);

        tuftsMask = bwareaopen(tuftsMask,prod(blockSize) + 1);
    
        %% Save Tuft Images
        if doSaveImages
            
            quadNW=cat(3, uint8(tuftsMask).*redImage,redImage, redImage);
            quadNE=cat(3, redImage, redImage, redImage);
            
            quadNW=imcrop(quadNW, maskStats.BoundingBox/scaleFactor);
            quadNE=imcrop(quadNE, maskStats.BoundingBox/scaleFactor);

            
            imwrite([quadNW quadNE], fullfile(masterFolder, 'TuftImages', myFiles{it}), 'JPG')
            
        end % doSaveImages
        
        save(fullfile(masterFolder, 'TuftNumbers', [myFiles{it} '.mat']), 'tuftsMask');
        
    end % doTufts
    
outFlatMountArea(it)=sum(thisMask(:));
outBranchingPoints(it)=sum(brchPts(:));
outAVascularArea(it)=sum(aVascZone(:));
outVasculatureLength(it)=sum(vesselSkelMask(:));
outTuftArea(it)=sum(tuftsMask(:));
outTuftNumber(it)=max(max(bwlabel(tuftsMask)));
outEndPoints(it)=sum(endPts(:));


end


resultsTable = table;
resultsTable.FileName=myFiles';
resultsTable.FlatMountArea = outFlatMountArea';
resultsTable.BranchingPoints = outBranchingPoints';
resultsTable.AVascularArea = outAVascularArea';
resultsTable.VasculatureLength = outVasculatureLength';
resultsTable.TuftArea = outTuftArea';
resultsTable.TuftNumber = outTuftNumber';
resultsTable.EndPoints = outEndPoints';

writetable(resultsTable,fullfile(masterFolder, 'Reports', 'AnalysisResult.xls'))

end

