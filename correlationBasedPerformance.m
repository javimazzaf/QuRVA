% loads local parameters
readConfig;

%Ensures everything is commited before starting test.
[versionInfo.branch, versionInfo.sha] = getGitInfo;

mkdir(masterFolder, 'Global')

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

%% Load results

for it=1:numel(myFiles)
    disp(myFiles{it});
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    
    load(fullfile(masterFolder,'manualAndSwiftMasks',myFiles{it}), 'manualMasks','swiftMasks','users')

    manualMasks = resetScale(manualMasks);
    swiftMasks  = resetScale(swiftMasks);
    
    consensusMask = sum(manualMasks, 3) >= consensus.reqVotes;   
    
    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    [thisMask,scaleFactor] = resetScale(thisMask);
    thisONCenter = thisONCenter/scaleFactor;
    
    [maskStats, maskNoCenter] = processMask(thisMask, consensusMask, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    consensusArea(it) = sum(consensusMask(validMask(:)));
    
    % Each Evaluator
    for itUsers=1:size(manualMasks,3)
        manualMask = manualMasks(:,:,itUsers);
        manualAreas(it,itUsers,1) = sum(manualMask(validMask(:)));
        
        swiftMask = swiftMasks(:,:,itUsers);
        sumSwift  = sum(swiftMask(validMask(:)));
        if sumSwift ~= 0
            manualAreas(it,itUsers,2) = sum(swiftMask(validMask(:)));
        else
            manualAreas(it,itUsers,2) = NaN;
        end
    end

end



