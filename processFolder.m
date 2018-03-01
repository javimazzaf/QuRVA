function processFolder(varargin)
% Entry function for QuRVA (see readme.txt)
% Parameters (optional): If not included it uses the default behaviour
% varargin{1} = masterFolder (string with folder path) default: config.ini
% varargin{2} = myFiles (particular file names in a cellarray): default: files in master folder
% varargin{3} = model (object containint QDA object): default model.mat in current folder

% *************************************************************************
% Copyright (C) 2018 Javier Mazzaferri and Santiago Costantino 
% <javier.mazzaferri@gmail.com>
% <santiago.costantino@umontreal.ca>
% Hopital Maisonneuve-Rosemont, 
% Centre de Recherche
% www.biophotonics.ca
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% *************************************************************************

try
    % Settings and folders
    readConfig
    
    if nargin > 0, masterFolder=varargin{1};
    else,          masterFolder = uigetdir('', 'Select folder'); end
    
    if nargin > 1, myFiles = varargin{2}; 
    else,          myFiles = getImageList(masterFolder); end
    
    if nargin > 2, model = varargin{3};
    else,          load('model.mat','model'); end
    
    % Create auxiliary folders
    warnStruct = warning('Off');
        mkdir(masterFolder, 'Masks')
        mkdir(masterFolder, 'TuftImages')
        mkdir(masterFolder, 'TuftNumbers')
        mkdir(masterFolder, 'VasculatureImages')
        mkdir(masterFolder, 'VasculatureNumbers')
        mkdir(masterFolder, 'ONCenter')
        mkdir(masterFolder, 'Reports')
    warning(warnStruct)
    
    % Create retinal mask and center
    computeMaskAndCenter(masterFolder, myFiles);
    
    myFiles = myFiles(:);
    
    % Allocate arrays to hold results
    outFlatMountArea     = zeros(size(myFiles));
    outBranchingPoints   = zeros(size(myFiles));
    outAVascularArea     = zeros(size(myFiles));
    outVasculatureLength = zeros(size(myFiles));
    outTuftArea          = zeros(size(myFiles));
    outTuftNumber        = zeros(size(myFiles));
    outEndPoints         = zeros(size(myFiles));
    
    % Process each image file
    for it=1:numel(myFiles)
        try
            disp(['Processing: ' myFiles{it}])
            
            % Read image
            thisImage = imread(fullfile(masterFolder, myFiles{it}));
            redImage  = thisImage(:,:,1);
            
            % Convert to 8bits unsigned integer
            redImage = im2uint8(redImage);
            
            % Load Mask and Center
            load(fullfile(masterFolder, 'Masks',    [myFiles{it} '.mat']), 'thisMask');
            load(fullfile(masterFolder, 'ONCenter', [myFiles{it} '.mat']), 'thisONCenter');
            
            % Adjust retinal region. Trim edges and the center.
            [maskStats, maskNoCenter] = processMask(thisMask, thisONCenter);
            
            [redImage, scaleFactor] = resetScale(redImage);
            thisMask     = resetScale(thisMask);
            maskNoCenter = resetScale(maskNoCenter);
            thisONCenter = thisONCenter/scaleFactor;
            retinaDiam   = computeRetinaSize(thisMask, thisONCenter);
            
            % Computes the area of the whole retina
            outFlatMountArea(it) = sum(thisMask(:));
            
            if doVasculature
                
                disp('  Computing vasculature . . .')
                [vesselSkelMask, brchPts, smoothVessels, endPts] = getVacularNetwork(thisMask, redImage);
                aVascZone = getAvacularZone(thisMask, vesselSkelMask, retinaDiam, thisONCenter);
                
                % Make a nice image
                if doSaveImages
                    
                    leftHalf  = cat(3, redImage, redImage, redImage);
                    rightHalf = makeNiceVascularImage(redImage, aVascZone, vesselSkelMask, brchPts);
                    
                    leftHalf  = imcrop(leftHalf, maskStats.BoundingBox/scaleFactor);
                    rightHalf = imcrop(rightHalf, maskStats.BoundingBox/scaleFactor);
                    
                    imwrite([leftHalf rightHalf], fullfile(masterFolder, 'VasculatureImages', myFiles{it}), 'JPG')
                    
                end 
                
                save(fullfile(masterFolder, 'VasculatureNumbers', [myFiles{it},'.mat']),...
                    'vesselSkelMask', 'brchPts', 'aVascZone', 'endPts','smoothVessels');
                
                disp('  Vasculature done.')
                
                % Computes vasculature results
                outBranchingPoints(it)   = sum(brchPts(:));
                outAVascularArea(it)     = sum(aVascZone(:));
                outVasculatureLength(it) = sum(vesselSkelMask(:));
                outEndPoints(it)         = sum(endPts(:));
                
            end
            
            % Analyze tufts
            if doTufts
                
                disp('  Computing tufts . . .')
                
                tuftsMask = getTufts(redImage, maskNoCenter, thisMask, thisONCenter, retinaDiam, model);

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
                    
                    % Save image
                    imwrite(resultImage, fullfile(masterFolder, 'TuftImages', myFiles{it}), 'JPG')
                    
                end
                
                save(fullfile(masterFolder, 'TuftNumbers', [myFiles{it} '.mat']), 'tuftsMask');
                
                % For Results
                outTuftArea(it)          = sum(tuftsMask(:));
                outTuftNumber(it)        = max(max(bwlabel(tuftsMask)));
                
                disp('  Tufts done.')
                
            end
            
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



