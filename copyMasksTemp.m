masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/ToTest/';

for it=1:numel(newFilenames)
    copyfile([masterFolder 'Masks/' myFiles(it).name '.mat'],...
        [masterFolder 'Anonymous/Masks/' newFilenames{it} '.mat'])
end