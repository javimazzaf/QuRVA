function collectUsersAndSwiftMasks 

rotatedAngles = -90 * [1 0 1 1 1 0 1 1 1 0 0 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 1];

% loads local parameters
readConfig

testersFolder = '/Users/javimazzaf/Dropbox (Biophotonics)/Testers';

% Get tester names
testerFiles = dir(fullfile(testersFolder,'*.tiff'));
users = cellfun(@(x) regexp(x,'^.*(?=(\.tiff))','match'),{testerFiles(:).name});

% Get image files names
rawFileNames = dir(fullfile(masterFolder,'Im*'));

resDir = fullfile(masterFolder, 'manualAndSwiftMasks');

if ~exist(resDir,'dir'), mkdir(resDir); end

% Computes the consensus for each image
for it = 1:14 
    
    for itUser = 1:numel(users)
        
        testerImage  = imread(fullfile(testersFolder, [users{itUser} '.tiff']),it);
        testerImage  = imrotate(testerImage, rotatedAngles(it));
        thisRawImage = imread(fullfile(masterFolder, rawFileNames(it).name));
        thisRawImage = thisRawImage(:,:,1);
        
        trimedImage  = trimThisImage(testerImage);
        
        magentaMaskOriginal = createMagentaMask(trimedImage);
        
        manualMasks(:,:,itUser) = imresize(logical(magentaMaskOriginal), size(thisRawImage));
        
        swiftMasks(:,:,itUser) = getSwiftMask(fullfile(masterFolder,'SWIFT'), rawFileNames(it).name, users{itUser}, thisRawImage);
        
    end
    
    save(fullfile(resDir,[rawFileNames(it).name '.mat']), 'manualMasks','swiftMasks','users')
    
    clear manualMasks swiftMasks
    
end

