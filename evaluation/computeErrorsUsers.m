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
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'allMasks')
    allMasks = resetScale(allMasks);
    consensusMask = sum(allMasks, 3) >= consensus.reqVotes;   
    
    load(fullfile(masterFolder,'SwiftMasks',myFiles{it}),'swiftMasks')
    swiftMasks = resetScale(swiftMasks);    
    
    load(fullfile(masterFolder, 'Masks',    myFiles{it}), 'thisMask');
    load(fullfile(masterFolder, 'ONCenter', myFiles{it}), 'thisONCenter');
    [thisMask,scaleFactor] = resetScale(thisMask);
    thisONCenter = thisONCenter/scaleFactor;
    
    [maskStats, maskNoCenter] = processMask(thisMask, consensusMask, thisONCenter);
    
    validMask = maskNoCenter & thisMask;
    
    % Each Evaluator
    for itUsers=1:size(allMasks,3)
        currentMask = allMasks(:,:,itUsers);
        FPothers(itUsers,it) = sum(currentMask(validMask(:)) > consensusMask(validMask(:)));
        FNothers(itUsers,it) = sum(currentMask(validMask(:)) < consensusMask(validMask(:)));
    end
    
    % Each Swift
    for itSwift = 1:size(swiftMasks,3)
        currentMask = swiftMasks(:,:,itSwift);
        
        %Check if I got zeros because the user did not analyze this image
        if max(currentMask(:)) == 0
            FPothers(itUsers+itSwift,it) = NaN;
            FNothers(itUsers+itSwift,it) = NaN;
        else
            FPothers(itUsers+itSwift,it) = sum(currentMask(validMask(:)) > consensusMask(validMask(:)));
            FNothers(itUsers+itSwift,it) = sum(currentMask(validMask(:)) < consensusMask(validMask(:)));
        end
        
    end

end

save(fullfile(masterFolder,'comparisonOthers.mat'),'FPothers','FNothers','versionInfo')


