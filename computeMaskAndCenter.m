function computeMaskAndCenter(masterFolder, fileNames)

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
    
    if ~existCenter

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
end