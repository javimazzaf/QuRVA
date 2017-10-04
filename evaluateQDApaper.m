readConfig

load(fullfile(masterFolder, 'modelPaper.mat'),'model1','model2')

myFiles = dir(fullfile(masterFolder, 'Masks','*.mat'));
myFiles = {myFiles(:).name};

myFiles = cellfun(@(x) x(1:end-4),myFiles,'UniformOutput',false);

processFolder(masterFolder,myFiles(1:7), model2,true);
processFolder(masterFolder,myFiles(8:14),model1,true);
