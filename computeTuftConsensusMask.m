function [allMasks, consensusMask] = computeTuftConsensusMask(imName)

testersFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/Testers/';
% loads local parameters
if exist('localConfig.m','file'), localConfig; end

matFiles=dir([testersFolder '*.mat']);

for it=1:numel(matFiles)

    load([testersFolder matFiles(it).name]);
    
    allMasks(:,:,it)=magentaMasks{imageId};
   
end

consensusMask=round(mean(allMasks, 3));

end