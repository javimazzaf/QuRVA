clear 
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/FlatMounts/IOVS/';

pWeeks=2:7;

mutants={'WT' 'Lyz' 'NrpLyz'};

for itMutants=2:3
    for itWeek=2:7
        thisFolder=[masterFolder mutants{itMutants} filesep 'P' num2str(itWeek) filesep] 
        processFolder(thisFolder)
    end
end