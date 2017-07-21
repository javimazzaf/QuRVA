readConfig

load(fullfile(masterFolder, 'trainingSet.mat'),'data','res')
% trainingSetVersInfo = versionInfo;

model = fitcdiscr(data,res,'DiscrimType','quadratic','Cost',tufts.classCost,'Prior','empirical');

save(fullfile(masterFolder, 'model.mat'),'model','-v7.3')