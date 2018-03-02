function computeMaskAndCenter(masterFolder, fileNames)
% Defines the region of the retina and its center, either automitically or
% interactivelly. See parameter "computeMaskAndCenterAutomatically" in
% parameters.ini file.

% The retinal region is stored in individual files within the
% "Masks" subfolder.

% The center coordinates are stores in individual files within the
% "ONCenter" subfolder

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

readConfig

warningState = warning;

try
    
    for it = 1:numel(fileNames)
        
        clear thisMask fg
        
        % Compute mask and Center fileNames
        maskFile   = fullfile(masterFolder, 'Masks', [fileNames{it} '.mat']);
        centerFile = fullfile(masterFolder, 'ONCenter', [fileNames{it} '.mat']);
        
        % If both exist skip to next image
        existMask   = exist(maskFile,'file');
        existCenter = exist(centerFile,'file');
        if existMask && existCenter, continue, end
        
        thisImage = imread(fullfile(masterFolder, fileNames{it}));
        redImage  = thisImage(:,:,1);
        
        %% Load mask and center
        if ~existMask
            
            % Compute automatic retinal region
            thisMask = getMask(redImage);
            
            if ~computeMaskAndCenterAutomatically
                fg = figure;
                warning('Off')
                imshow(imoverlay(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),imdilate(bwperim(thisMask),strel('disk',5)),'m'))
                warning(warningState)
            end
            
            while true
                
                if ~computeMaskAndCenterAutomatically && strcmp(questdlg('Is the mask correct?', 'Confirmation','Yes','No','Yes'),'No')
                    imshow(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),[])
                    thisMask=roipoly;
                    warning('Off')
                    imshow(imoverlay(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),imdilate(bwperim(thisMask),strel('disk',5)),'m'))
                    warning(warningState)
                else
                    save(maskFile, 'thisMask');
                    break
                end
            end
            
        end
        
        if ~existCenter
            
            % Estimate center from mask
            if ~exist('thisMask','var')
                load(maskFile, 'thisMask');
            end
            
            maskProps    = regionprops(thisMask,'Centroid');
            thisONCenter = maskProps.Centroid;
            
            while true
                
                if computeMaskAndCenterAutomatically
                    save(centerFile, 'thisONCenter');
                    break
                end
                
                if ~exist('fg','var')
                    fg = figure;
                    
                    warning('Off')
                    imshow(imoverlay(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),imdilate(bwperim(thisMask),strel('disk',5)),'m'))
                    warning(warningState)
                end
                
                hold on
                
                plot(thisONCenter(1), thisONCenter(2), '*m')
                
                if strcmp(questdlg('Should center of the optic nerve head be here?', 'Confirmation','Yes','No','Yes'),'Yes')
                    save(centerFile, 'thisONCenter');
                    break
                end
                
                clf(fg)
                warning('Off')
                imshow(imoverlay(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),imdilate(bwperim(thisMask),strel('disk',5)),'m')), hold on
                imshow(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),[]), hold on
                warning(warningState)
                
                title('Click on the center of the optic nerve head')
                [x,y] = ginput(1);
                thisONCenter=round([x y]);
                
            end
            
        end
        
        if exist('fg','var'), close(fg); clear fg; end
        
    end
    
catch err
    disp(['Error in computeMaskAndCenter. Message: ' err.message buildCallStack(err)]);
    warning(warningState)
end

end