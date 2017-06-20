clear


% loads local parameters
readConfig;

load([masterFolder, 'TrainingDB/allBlocks.mat'], 'smallBlocks')

digitData = imageDatastore([masterFolder 'TrainingDB/'], ...
        'IncludeSubfolders',true,'FileExtensions', '.tif',...
        'LabelSource','foldernames');
    
    %%
    

trainingNumFiles = 1000;
rng(5) % For reproducibility
[trainDigitData,testDigitData] = splitEachLabel(digitData, ...
				trainingNumFiles,'randomize');
            
%%
layers = [imageInputLayer([28 28 1])
convolution2dLayer(5,20)
reluLayer
maxPooling2dLayer(2,'Stride',2)
fullyConnectedLayer(2)
softmaxLayer
classificationLayer()];

%%
options = trainingOptions('sgdm','MaxEpochs',15, ...
	'InitialLearnRate',0.0001);

%%
convnet = trainNetwork(trainDigitData,layers,options);

%%
YTest = classify(convnet,testDigitData);
TTest = testDigitData.Labels;
%%
accuracy = sum(YTest == TTest)/numel(TTest)

save('myNetwork.mat', 'convnet')