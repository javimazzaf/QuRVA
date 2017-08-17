function collectSingleUserTufts(userName)

% Including code path safely
codeDirectory = '..';
addpath(codeDirectory);
toDelete = onCleanup(@() rmpath(codeDirectory));

rotatedAngles = -90 * [1 0 1 1 1 0 1 1 1 0 0 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 1];

masterFolder = '/Users/javimazzaf/Documents/work/proyectos/flatMounts/Anonymous/';

% loads local parameters
readConfig

% Get tester names

testerFile = fullfile('/Users/javimazzaf/Dropbox (Biophotonics)/Biophotonics Team Folder/Javier/flatMounts/modelImprovement/',...
                     ['testingImages' userName '.tiff']);

% Get image files names
rawFileNames = dir(fullfile(masterFolder,'Im*'));

if ~exist(fullfile(masterFolder,'TuftConsensusMasks',userName),'dir')
    mkdir(fullfile(masterFolder,'TuftConsensusMasks',userName));
end

% Computes the consensus for each image
for it = 1:numel(rawFileNames)
    
    testerImage  = imread(testerFile,it);
    testerImage  = imrotate(testerImage, rotatedAngles(it));
    thisRawImage = imread(fullfile(masterFolder, rawFileNames(it).name));
    thisRawImage = thisRawImage(:,:,1);
    
    trimedImage  = trimThisImage(testerImage);
    
    magentaMaskOriginal = createMagentaMask(trimedImage);
    
    if ~any(magentaMaskOriginal(:)), continue, end
    
    allMasks = imresize(logical(magentaMaskOriginal), size(thisRawImage));
    
    consensusMask = allMasks;
    
    orMask = allMasks;
    
    save(fullfile(masterFolder,'TuftConsensusMasks', userName, [rawFileNames(it).name '.mat']), 'allMasks','consensusMask','orMask')
    
end

