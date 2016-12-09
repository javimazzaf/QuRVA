clear 
masterFolder='/Users/santiago/Dropbox (Biophotonics)/Projects/Bruno/Images/IOVS/NrpLyz';

pWeeks=2:7;

for it=1:numel(pWeeks)

    %% Get file names
    myFiles=dir([masterFolder filesep 'P' num2str(pWeeks(it)) filesep '*.jpg']);
    
    if numel(myFiles)==0
        myFiles=dir([masterFolder filesep 'P' num2str(pWeeks(it)) filesep '*.tif']);
    end
    
    for itFile=1:numel(myFiles)
        load([masterFolder filesep 'P' num2str(pWeeks(it)) filesep 'VasculatureNumbers' filesep myFiles(itFile).name '.mat'])
        load([masterFolder filesep 'P' num2str(pWeeks(it)) filesep 'Masks' filesep myFiles(itFile).name '.mat'])
        skelLength=sum(sum(vesselSkelMask));
        skelRatio(itFile)=double(skelLength)/double(sum(sum(thisMask)));
    end
    
    pSkelMean(it)=mean(skelRatio);
    pSkelSTD(it)=std(skelRatio);
    
end
