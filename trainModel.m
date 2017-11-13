% Train Random Forrest
readConfig

% Delete old features and models
delete(fullfile(masterFolder, 'trainingSet.mat'))
delete(fullfile(masterFolder, 'model.mat'))

% Compute features
getTrainingSet;

% Build model
createModel;