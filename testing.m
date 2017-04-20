% testing

threshold = 0.5;
outMask = enhancedTufts >= threshold;
thickMask = outMask;
tuftsMask = logical(thickMask) .* maskNoCenter;

load(fullfile(masterFolder,'TuftConsensusMasks',['Image002.jpg.mat']),'allMasks','consensusMask')
redImage = rawImage; 
imErrors = imoverlay(imoverlay(imoverlay(redImage, uint8(tuftsMask-consensusMask>0)*255, 'm'), uint8(tuftsMask-consensusMask<0)*255, 'y'), uint8(and(consensusMask, tuftsMask))*255, 'g');
figure; 