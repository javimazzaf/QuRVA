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
    tuftsMask = resetScale(tuftsMask);
    
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
    
    quRVAArea(it) = sum(tuftsMask(validMask(:)));
    
    % Each Evaluator
    for itUsers=1:size(manualMasks,3)
        manualMask = manualMasks(:,:,itUsers);
        manualAreas(it,itUsers,1) = sum(manualMask(validMask(:)));
        
        swiftMask = swiftMasks(:,:,itUsers);
        sumSwift  = sum(swiftMask(validMask(:)));
        if sumSwift ~= 0
            manualAreas(it,itUsers,2) = sumSwift;
        else
            manualAreas(it,itUsers,2) = NaN;
        end
    end

end

% Save
save(fullfile(masterFolder,'manualSwiftCorrelation.mat'), 'consensusArea', 'manualAreas', 'quRVAArea', 'users')

%% Plots
readConfig;
load(fullfile(masterFolder,'manualSwiftCorrelation.mat'), 'consensusArea', 'manualAreas', 'quRVAArea', 'users')

usuario1 = 2;
usuario2 = 4;
% manSwift = 1;

set1 = consensusArea(:);
set2 = quRVAArea(:);

% set1 = manualAreas(:,usuario1,1);
% set2 = manualAreas(:,usuario2,2);

[R,P] = corrcoef(set1,set2)

plot(set1,set2,'.k')

