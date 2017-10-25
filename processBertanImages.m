% Uses Bertan images to train or to process them
% Can run from Mac(by mounting Eye/home/Javier) or from Eye itself
% It takes a list of training images stored in variable trainingImages
% loaded from paramenters.ini using readConfig

function processBertanImages(train)

readConfig

if ismac,      basePath = '/Volumes/EyeFolder/';
elseif isunix, basePath = '~/';
end

imPath = fullfile(basePath,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/');

maskFiles = dir(fullfile(imPath,'Masks','*.mat'));
maskFiles = {maskFiles(:).name};

allFiles = cellfun(@(x) x(1:end-4),maskFiles,'UniformOutput',false);

fileIds = regexp(allFiles,'([0-9]+_[a-zA-Z]+)(?=_original\.tif)','match');

if train
    trainPath = fullfile(basePath,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/');

    modelDir = fullfile(basePath, 'Dropbox (Biophotonics)/Deep_learning_Images/OIR/trainingSwift/');
    
    if ~exist(modelDir,'dir')
        mkdir(modelDir);
    end
    
    % Select images for training
    trainIx = ismember([fileIds{:}],trainingImages');
    
    computeBertanTrainingSet(imPath,trainPath,allFiles(trainIx),fullfile(modelDir,'trainingSet.mat'))
else
    % Exclude training images
    noTrainIx = ~ismember([fileIds{:}],trainingImages');
    
    processFolder(imPath,allFiles(noTrainIx));
end
