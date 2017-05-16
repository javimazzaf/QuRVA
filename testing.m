%%
readConfig
load(fullfile(masterFolder, 'trainingSet.mat'),'data','res')

% extra_options.DEBUG_ON
% extra_options.replace
% extra_options.classwt
% extra_options.cutoff
% extra_options.strata
% extra_options.sampsize
% extra_options.nodesize
extra_options.importance = 1;
% extra_options.localImp
% extra_options.nPerm
% extra_options.proximity
% extra_options.oob_prox
extra_options.do_trace = 1;
% extra_options.keep_inbag

ntree = 0;
mtry  = 0;

model = classRF_train(data,res,ntree,mtry,extra_options);

save(fullfile(masterFolder, 'model.mat'),'model','-v7.3')

%%
load(fullfile(masterFolder, 'model.mat'),'model')

smIm = imgaussfilt(oImage,5);

candidatesMsk = imbinarize(smIm, adaptthresh(smIm, 'NeighborhoodSize', [51 51])) & validMask;

candidateBlocks  = getBlocksInMask(indBlocks, candidatesMsk, 50);

blockFeatures = computeBlockFeatures(oImage,validMask, indBlocks,candidateBlocks,[]);

y = classRF_predict(blockFeatures,model);

goodBlocks = candidateBlocks(y > 0.5,:);

resIm = blocksToMask(size(oImage), indBlocks, goodBlocks);

%%
% set(0,'DefaultFigureWindowStyle','docked')

load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask');
% resIm = candidatesMsk;
% figure(1), imshow(oImage,[]); 
rgb=imoverlay(imoverlay(imoverlay(oImage, uint8(resIm-consensusMask>0)*255, 'm'), uint8(resIm-consensusMask<0)*255, 'y'), uint8(and(consensusMask, resIm))*255, 'g');
figure(2), imshow(rgb,[]);
print(2,'')

% set(0,'DefaultFigureWindowStyle','normal')

%%
% sz
% bSz
% nBlocks

% padSz   = nBlocks .* bSz - size(inIm);
    
% inIm = padarray(inIm,padSz,0,'post');

ImTrue  = zeros(12*25,20*25);
ImFalse = zeros(12*25,20*25);

for k = 1:240
    aux = inIm(blocksInd(:,:,selBlocks(k,1),selBlocks(k,2)));
%     aux = aux / sum(aux(:));
    [r,c] = ind2sub([12,20],k);
    ImTrue((r-1)*25+1:r*25,(c-1)*25+1:c*25) = aux;
end

for k = 1:240
    
    aux = inIm(blocksInd(:,:,selBlocks(k+240,1),selBlocks(k+240,2)));
%     aux = aux / sum(aux(:));
    [r,c] = ind2sub([12,20],k);
    ImFalse((r-1)*25+1:r*25,(c-1)*25+1:c*25) = aux;
end

