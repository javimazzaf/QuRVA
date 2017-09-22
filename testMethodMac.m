imPath = '../Anonymous/';

maskFiles = dir(fullfile(imPath,'Masks','*.mat'));
maskFiles = {maskFiles(:).name};

allFiles = cellfun(@(x) x(1:end-4),maskFiles,'UniformOutput',false);

processFolder(imPath,allFiles(21:2:end)); 
