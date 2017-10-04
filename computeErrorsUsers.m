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
    
    % Each Evaluator
    for itUsers=1:size(allMasks,3)
        FPothers(itUsers,it) = sum(sum(allMasks(:,:,itUsers) > consensusMask));
        FNothers(itUsers,it) = sum(sum(allMasks(:,:,itUsers) < consensusMask));
    end
    
    % Each Swift
    for itSwift = 1:size(swiftMasks,3)
        
        %Check if I got zeros because the user did not analyze this image
        if max(max(swiftMasks(:,:,itSwift))) == 0
            FPothers(itUsers+itSwift,it) = NaN;
            FNothers(itUsers+itSwift,it) = NaN;
        else
            FPothers(itUsers+itSwift,it) = sum(sum(swiftMasks(:,:,itSwift) > consensusMask));
            FNothers(itUsers+itSwift,it) = sum(sum(swiftMasks(:,:,itSwift) < consensusMask));  
        end
        
    end

end

save(fullfile(masterFolder,'comparisonOthers.mat'),'FPothers','FNothers','versionInfo')





