clear
% loads local parameters
if exist('localConfig.m','file'), localConfig; end

warning('Off')
mkdir(masterFolder, 'Masks')
mkdir(masterFolder, 'TuftImages')
mkdir(masterFolder, 'TuftNumbers')
mkdir(masterFolder, 'VasculatureImages')
mkdir(masterFolder, 'VasculatureNumbers')

doTufts=1;
doVasculature=0;

%% Get file names
myFiles=dir(fullfile(masterFolder, '*.jpg'));
if isempty(myFiles)
    myFiles=dir(fullfile(masterFolder, '*.tif'));
end
myFiles = {myFiles(:).name}; % Make a cell array

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

    %% Get observers data
    load(fullfile(masterFolder,'TuftConsensusMasks',[myFiles{it} '.mat']),'allMasks','consensusMask')

    [tuftsMask,~,~] = getTufts(thisMask, redImage, maskNoCenter);
     
end

