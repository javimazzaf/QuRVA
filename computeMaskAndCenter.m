function computeMaskAndCenter(masterFolder, fileNames,fullAuto)

%Makes sure warning are turned off at return of the function
finishup = onCleanup(@() warning('On'));

% Default is supervised
if ~exist('fullAuto','var'), fullAuto = false; end

for it = 1:numel(fileNames)
    
    % Compute mask and Center fileNames
    maskFile   = fullfile(masterFolder, 'Masks', [fileNames{it} '.mat']);
    centerFile = fullfile(masterFolder, 'ONCenter', [fileNames{it} '.mat']);  
    
    % If both exist skip to next
    existMask   = exist(maskFile,'file');
    existCenter = exist(centerFile,'file');
    if existMask && existCenter, continue, end
    
    thisImage = imread(fullfile(masterFolder, fileNames{it}));
    redImage  = thisImage(:,:,1);
    
    %% Load mask and center
    if ~existMask

        thisMask = getMask(redImage);
        
        if ~fullAuto
          fg = figure;
          warning('Off')
          imshow(imoverlay(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),imdilate(bwperim(thisMask),strel('disk',5)),'m'))
          warning('On')
        end
        
        while true
            
            if ~fullAuto && strcmp(questdlg('Is the mask correct?', 'Confirmation','Yes','No','Yes'),'No')
                imshow(redImage,[])
                thisMask=roipoly(thisImage);
                warning('Off')
                imshow(imoverlay(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),imdilate(bwperim(thisMask),strel('disk',5)),'m'))
                warning('On')
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
            
            if fullAuto
                save(centerFile, 'thisONCenter');
                break
            end
            
            if exist('fg','var'), clf(fg)
            else                , fg = figure; end

            warning('Off')
            imshow(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),[]), hold on
            plot(thisONCenter(1), thisONCenter(2), '*m')
            warning('On')

            if strcmp(questdlg('Should center of the optic nerve head be here?', 'Confirmation','Yes','No','Yes'),'Yes')
                save(centerFile, 'thisONCenter');
                break
            end
            
            clf(fg)
            warning('Off')
            imshow(imadjust(redImage,stretchlim(redImage,[0.01 0.97])),[]), hold on
            warning('On')
            title('Click on the center of the optic nerve head')
            [x,y] = ginput(1);
            thisONCenter=round([x y]);
            
        end
        
    end
    
    if exist('fg','var'), close(fg); clear fg; end
end