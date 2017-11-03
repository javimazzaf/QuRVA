clear

% loads local parameters
readConfig;

mkdir(masterFolder, 'Global')

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

%% Load results
allDiffFrac = [];
for it=1:14 %numel(myFiles)
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'consensusMask')
    swiftMasks = collectSwift(masterFolder, myFiles{it}, consensusMask);
        
    diffFrac = [];
    for k=1:size(swiftMasks,3)
        kMask = logical(swiftMasks(:,:,k));
        if max(max(kMask))==0, continue, end

        for s = k+1:size(swiftMasks,3)
           sMask = logical(swiftMasks(:,:,s)); 
           if max(max(kMask))==0, continue, end
           
           allPix = sum(or(kMask(:),sMask(:)));
           difPix = sum(xor(kMask(:),sMask(:)));
           
           diffFrac = [diffFrac, difPix / allPix];
           k,s
           
        end

    end
    
    allDiffFrac = [allDiffFrac, mean(diffFrac)];
    
end

plot(allDiffFrac)


