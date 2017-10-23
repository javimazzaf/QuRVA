%Training a model using several swift images from Bertan
function testSwiftTraining(train)

readConfig

if ismac
    basePath = '/Volumes/EyeFolder/';
%     basePath = '/Users/javimazzaf/';
elseif isunix
    basePath = '~/';
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
    
    trainIx = ismember([fileIds{:}],trainingImages');
    
    trainQuRVA(imPath,trainPath,allFiles(trainIx),fullfile(modelDir,'trainingSet.mat'),fullfile(modelDir,'model.mat'))
else
    %    processFolder(imPath,allFiles(51:23:end));
    noTrainIx = ~ismember([fileIds{:}],trainingImages');
    processFolder(imPath,allFiles(noTrainIx));
%      processFolder(imPath,allFiles(1:50));
end
