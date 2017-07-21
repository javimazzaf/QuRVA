readConfig

load(fullfile(masterFolder, 'trainingSet.mat'),'data1','res1','data2','res2','versionInfo')
trainingSetVersInfo = versionInfo;

model1 = fitcdiscr(data1,res1,'DiscrimType','quadratic','Cost',tufts.classCost,'Prior','empirical');
model2 = fitcdiscr(data2,res2,'DiscrimType','quadratic','Cost',tufts.classCost,'Prior','empirical');

save(fullfile(masterFolder, 'model.mat'),'model1','model2','trainingSetVersInfo','-v7.3')