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

save(fullfile(masterFolder, 'model.mat'),'model')

%%
load(fullfile(masterFolder, 'model.mat'),'model')


smIm = imgaussfilt(oImage,5);

candidatesMsk = imbinarize(smIm, adaptthresh(smIm, 'NeighborhoodSize', [51 51])) & validMask;
% candidatesMsk = (oImage > max(oImage) * 0.75) & validMask;
ind = find(candidatesMsk);
imFeatures = computeImageFeatures(oImage, validMask,ind,[]);
y = classRF_predict(imFeatures,model);
tuftInd = ind(y > 0.5);
resIm = zeros(size(oImage));
resIm(tuftInd) = true;

%%
set(0,'DefaultFigureWindowStyle','docked')

load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask');
% resIm = candidatesMsk;
figure(1), imshow(oImage,[]); 
rgb=imoverlay(imoverlay(imoverlay(oImage, uint8(resIm-consensusMask>0)*255, 'm'), uint8(resIm-consensusMask<0)*255, 'y'), uint8(and(consensusMask, resIm))*255, 'g');
figure(2), imshow(rgb,[]);   

set(0,'DefaultFigureWindowStyle','normal')

