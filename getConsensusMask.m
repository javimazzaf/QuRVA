function [allMasks consensusMask]=getConsensusMask(imageId)

masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/Testers/';

matFiles=dir([masterFolder '*.mat']);

for it=1:numel(matFiles)

    load([masterFolder matFiles(it).name]);
    
    allMasks(:,:,it)=magentaMasks{imageId};
   
end

consensusMask=round(mean(allMasks, 3));