function collectUsersTufts 

rotatedAngles = -90 * [1 0 1 1 1 0 1 1 1 0 0 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 1];

masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/PaperImageSet/Anonymous/';

% loads local parameters
readConfig

% Get tester names
testerFiles = dir(fullfile(masterFolder,'Testers','*.tiff'));
users = cellfun(@(x) regexp(x,'^.*(?=(\.tiff))','match'),{testerFiles(:).name});

% Get image files names
rawFileNames = dir(fullfile(masterFolder,'Im*'));

if ~exist(fullfile(masterFolder,'TuftConsensusMasks'),'dir')
    mkdir(fullfile(masterFolder,'TuftConsensusMasks'));
end

% Computes the consensus for each image
for it = 1:14 
    
    for itUser = 1:numel(users)
        
        testerImage  = imread(fullfile(masterFolder, 'Testers', [users{itUser} '.tiff']),it);
        testerImage  = imrotate(testerImage, rotatedAngles(it));
        thisRawImage = imread(fullfile(masterFolder, rawFileNames(it).name));
        thisRawImage = thisRawImage(:,:,1);
        
        trimedImage  = trimThisImage(testerImage);
        
        magentaMaskOriginal = createMagentaMask(trimedImage);
        
        allMasks(:,:,itUser) = imresize(logical(magentaMaskOriginal), size(thisRawImage));
        
    end
    
    consensusMask = sum(allMasks, 3)>ceil(size(allMasks, 3)/2);
    
    orMask   = logical(sum(allMasks, 3));
    
    save(fullfile(masterFolder,'TuftConsensusMasks',[rawFileNames(it).name '.mat']), 'allMasks','consensusMask','orMask')
    
    clear allMasks
    
end

