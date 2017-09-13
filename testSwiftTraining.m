%Training a model using several swift images from Bertan 

basePath = '/Volumes/EyeFolder/';

imPath = fullfile(basePath,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/raw/');

maskFiles = dir(fullfile(imPath,'Masks','*.mat'));
maskFiles = {maskFiles(:).name};

allFiles = cellfun(@(x) x(1:end-4),maskFiles,'UniformOutput',false);

trainPath = fullfile(basePath,'Dropbox (Biophotonics)/Deep_learning_Images/OIR/swift/');

modelDir = fullfile(basePath, 'Dropbox (Biophotonics)/Deep_learning_Images/OIR/trainingSwift/');
if ~exist(modelDir,'dir')
    mkdir(modelDir);
end

train = true;

if train
   trainQuRVA(imPath,trainPath,allFiles(1:50),fullfile(modelDir,'trainingSet.mat'),fullfile(modelDir,'model.mat'))
else
   processFolder(fullfile(imPath,allFiles(51:end))); 
end
