function [allMasks consensusMask]=getAVascularConsensusMask(imageId)

localConfig

vascTestFolder=[testersFolder 'vascular/'];

matFiles=dir([vascTestFolder '*.mat']);

for it=1:numel(matFiles)

    load([vascTestFolder matFiles(it).name]);
    
    allMasks(:,:,it)=magentaMasks{imageId};
   
end

consensusMask=round(mean(allMasks, 3));