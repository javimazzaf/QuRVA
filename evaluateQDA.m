readConfig

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

load(fullfile(masterFolder, 'model.mat'),'model1','model2','trainingSetVersInfo')
load(fullfile(masterFolder, 'trainingSet.mat'),'blockSize')

myFiles = dir(fullfile(masterFolder, 'Masks','*.mat'));
myFiles = {myFiles(:).name};

for it=1:numel(myFiles)
    
    disp([num2str(it) '/' num2str(numel(myFiles))])
    
    fname = myFiles{it};
    fname = fname(1:end-4);
    
    oImage = imread(fullfile(masterFolder, fname));
    oImage = oImage(:,:,1);

    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    
    [maskStats, maskNoCenter] = processMask(thisMask, oImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}), 'allMasks');
    consensusMask = sum(allMasks, 3) >= consensus.reqVotes;
    
    [blocks, indBlocks] = getBlocks(oImage, blockSize(it,:), [0 0]);
    
    candidateBlocks  = getBlocksInMask(indBlocks, validMask, tufts.blocksInMaskPercentage, [0 0]);
    
    blockFeatures = computeBlockFeatures(oImage,maskNoCenter, thisMask, indBlocks,candidateBlocks,[],[0 0],thisONCenter);
    
    if it <= 7
        y = predict(model2, blockFeatures);
    else
        y = predict(model1, blockFeatures);
    end
    
    goodBlocks = candidateBlocks(y > 0.5,:);
    
    tuftsMask = blocksToMask(size(oImage), indBlocks, goodBlocks, [0 0]);
    
    tuftsMask = bwareaopen(tuftsMask,prod(blockSize(it,:)) + 1);

    votesImageRed   = .5*oImage;
    votesImageGreen = .5*oImage;
    votesImageBlue  = .5*oImage;
    
    myColors=prism;
    for ii=1:size(allMasks, 3)
        thisObserver=bwperim(allMasks(:,:,ii));
        votesImageRed(thisObserver~=0)=uint8(myColors(ii,1)*255);
        votesImageGreen(thisObserver~=0)=uint8(myColors(ii,2)*255);
        votesImageBlue(thisObserver~=0)=uint8(myColors(ii,3)*255);
        
    end
    votesImage=cat(3, votesImageRed, votesImageGreen, votesImageBlue);
    
    %% Save Tuft Images
    
    versionInfo.dayTag = datestr(now,'yyyymmdd_HH_MM');
    
    evaluationVersInfo = versionInfo;
    
    quadNW=cat(3, oImage, uint8(~tuftsMask).*oImage, uint8(~tuftsMask).*oImage);
    quadNE=cat(3, oImage, oImage, oImage);
    quadSW=imoverlay(imoverlay(imoverlay(oImage, uint8(tuftsMask-consensusMask>0)*255, 'm'), uint8(tuftsMask-consensusMask<0)*255, 'y'), uint8(and(consensusMask, tuftsMask))*255, 'g');
    quadSE=votesImage;
    
    imwrite([quadNW quadNE; quadSW quadSE], fullfile(masterFolder, 'TuftImages', fname), 'JPG','Comment',['TrainingVersion: ' trainingSetVersInfo.sha ' - EvaluationVersion: ' evaluationVersInfo.sha])
    
%     imwrite(quadNE, fullfile(masterFolder, 'TuftImagesPaper', ['original_' fname]), 'JPG','Comment',['TrainingVersion: ' trainingSetVersInfo.sha ' - EvaluationVersion: ' evaluationVersInfo.sha])
%     imwrite(quadSW, fullfile(masterFolder, 'TuftImagesPaper', ['errors_' fname]), 'JPG','Comment',['TrainingVersion: ' trainingSetVersInfo.sha ' - EvaluationVersion: ' evaluationVersInfo.sha])
    
    save(fullfile(masterFolder,'TuftNumbers',[myFiles{it}]),'tuftsMask', 'allMasks', 'consensusMask','evaluationVersInfo','trainingSetVersInfo');

end





