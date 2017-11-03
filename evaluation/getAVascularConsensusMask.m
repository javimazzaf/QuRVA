function [allMasks, consensusMask] = getAVascularConsensusMask(imageId)

readConfig;

vascTestFolder=[testersFolder 'vascular/'];

matFiles=dir([vascTestFolder '*.mat']);

for it=1:numel(matFiles)

    load([vascTestFolder matFiles(it).name]);
    
    allMasks(:,:,it)=magentaMasks{imageId};
   
end

consensusMask = sum(allMasks, 3) >= consensus.reqVotes;