function makeNiceTuftFigures

% loads local parameters
readConfig;

mkdir(fullfile(masterFolder,'NiceFigures'));

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

for it=1:numel(myFiles)
    
    disp(myFiles{it})
    
    imName = myFiles{it};
    imName = imName(1:end-4);
    
    redImage = imread(fullfile(masterFolder, imName));
    redImage = redImage(:,:,1);
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask','allMasks')
    
    %% Create votes Image
    votesImage = redImage;
    
    myColors=prism;
    for ii=1:size(allMasks, 3)
        thisObserver = logical(bwperim(allMasks(:,:,ii)));
        votesImage = imoverlay(votesImage,thisObserver,myColors(ii,:));
    end
    
    
    %% Save Tuft Images
    quadNW = cat(3, redImage, redImage, redImage);
    quadNE = imoverlay(redImage, tuftsMask, 'm');
    quadSW = votesImage;
    quadSE = imoverlay(redImage, consensusMask, 'g');
    
    imwrite([quadNW quadNE; quadSW quadSE], fullfile(masterFolder, 'NiceFigures', imName), 'JPG')
    
end







