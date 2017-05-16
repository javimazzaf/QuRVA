readConfig
load(fullfile(masterFolder, 'trainingSet.mat'),'data1','res1','data2','res2')

extra_options.importance = 1;
extra_options.do_trace = 1;

ntree = 0;
mtry  = 0;

model1 = classRF_train(data1,res1,ntree,mtry,extra_options);
model2 = classRF_train(data2,res2,ntree,mtry,extra_options);

save(fullfile(masterFolder, 'model.mat'),'model1','model2','-v7.3')