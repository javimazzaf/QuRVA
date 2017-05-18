readConfig

%Ensures everything is commited before starting test.
[branch, sha] = getGitInfo;

load(fullfile(masterFolder, 'model.mat'),'model1','model2')

myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

for it=1:numel(myFiles)
    
    disp(it)
    
    fname = myFiles{it};
    fname = fname(1:end-4);
    
    oImage = imread(fullfile(masterFolder, fname));
    oImage = oImage(:,:,1);

    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    
    [maskStats, maskNoCenter] = processMask(thisMask, oImage, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}), 'allMasks','consensusMask');
    
    summedMask = zeros(size(oImage));
    
    for k = 1:9
        
        [r, c] = ind2sub([3 3], k);
        
        step = ceil(tufts.blockSize / 3);
        
        offSet = min(([r, c] - 1) .* step,tufts.blockSize); 
        
        [blocks, indBlocks] = getBlocks(oImage, tufts.blockSize, offSet);
        
        candidateBlocks  = getBlocksInMask(indBlocks, validMask, 50, offSet);
        
        blockFeatures = computeBlockFeatures(oImage,validMask, indBlocks,candidateBlocks,[],offSet);
        
        if it <= 7
            y = classRF_predict(blockFeatures,model2);
        else
            y = classRF_predict(blockFeatures,model1);
        end
        
        goodBlocks = candidateBlocks(y > 0.5,:);
        
        summedMask = summedMask + blocksToMask(size(oImage), indBlocks, goodBlocks, offSet);
        
    end
    
    tuftsMask = summedMask >= tufts.BlockRequiredVotes;
    
    votesImageRed=.5*oImage;
    votesImageGreen=.5*oImage;
    votesImageBlue=.5*oImage;
    
    myColors=prism;
    for ii=1:size(allMasks, 3)
        thisObserver=bwperim(allMasks(:,:,ii));
        votesImageRed(thisObserver~=0)=uint8(myColors(ii,1)*255);
        votesImageGreen(thisObserver~=0)=uint8(myColors(ii,2)*255);
        votesImageBlue(thisObserver~=0)=uint8(myColors(ii,3)*255);
        
    end
    votesImage=cat(3, votesImageRed, votesImageGreen, votesImageBlue);
    
    %% Save Tuft Images
    
    quadNW=cat(3, oImage, uint8(~tuftsMask).*oImage, uint8(~tuftsMask).*oImage);
    quadNE=cat(3, oImage, oImage, oImage);
    quadSW=imoverlay(imoverlay(imoverlay(oImage, uint8(tuftsMask-consensusMask>0)*255, 'm'), uint8(tuftsMask-consensusMask<0)*255, 'y'), uint8(and(consensusMask, tuftsMask))*255, 'g');
    quadSE=votesImage;
    
    imwrite([quadNW quadNE; quadSW quadSE], fullfile(masterFolder, 'TuftImagesRF', fname), 'JPG')
    
    dayTag = datestr(now,'yyyymmdd_HH_MM');
    
    save(fullfile(masterFolder,'TuftNumbersRF',[myFiles{it}]),'tuftsMask', 'allMasks', 'consensusMask','branch', 'sha','dayTag');

end





