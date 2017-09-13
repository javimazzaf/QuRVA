%Training a model using several swift images from Bertan 

imPath = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/';

maskFiles = dir(fullfile(imPath,'Masks','*.mat'));
maskFiles = {maskFiles(:).name};

allFiles = cellfun(@(x) x(1:end-4),maskFiles,'UniformOutput',false);

trainPath = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/';

modelDir = '/Volumes/EyeFolder/Dropbox (Biophotonics)/Deep_learning_Images/OIR/trainingSwift/';
if ~exist(modelDir,'dir')
    mkdir(modelDir);
end

trainQuRVA(imPath,trainPath,allFiles(1:50),fullfile(modelDir,'trainingSet.mat'),fullfile(modelDir,'model.mat'))
