function [allMasks, consensusMask]=getTuftConsensusMask(imName)

masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/PaperImageSet/Anonymous/';

% loads local parameters
if exist('localConfig.m','file'), localConfig; end

fileName = fullfile(masterFolder,'TuftConsensusMasks',[imName '.mat']);

if exist(fileName,'file')
    load(fileName,'allMasks','consensusMask')
else
    [allMasks, consensusMask] = computeTuftConsensusMask(imName);
    save(fileName,'allMasks','consensusMask')
end

end

