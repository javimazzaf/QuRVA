function [auto, evaluator] = measureTuftComparativePerformance

% loads local parameters
readConfig;

%% Get file names
myFiles = dir(fullfile(masterFolder, 'TuftNumbers','*.mat'));
myFiles = {myFiles(:).name};

auto.FP = zeros(1,numel(myFiles));
auto.FN = zeros(1,numel(myFiles));

evaluator.FP = zeros(1,numel(myFiles));
evaluator.FN = zeros(1,numel(myFiles));

for it=1:numel(myFiles)
    
    load(fullfile(masterFolder, 'TuftNumbers', myFiles{it}),'tuftsMask');
    load(fullfile(masterFolder, 'TuftConsensusMasks',myFiles{it}),'allMasks')
    
    nEvals = size(allMasks,3);
    
    for e = 1:nEvals
        
        eMask = allMasks(:,:,e);
        otherMasks = allMasks(:,:,setdiff(1:nEvals,e));
        
        consensusMask = round(mean(otherMasks, 3)) > 0.5;
        unionMask     = sum(otherMasks,3) > 0.5;
        
        % Differences between our method and the consensus of the rest
        % evaluators
        ourDifConsensus = tuftsMask - consensusMask;
        ourDifUnion        = tuftsMask - unionMask;
        
        auto.FP(e,it) = sum(ourDifUnion(:) > 0.5);
        auto.FN(e,it) = sum(ourDifConsensus(:) < -0.5);
        
        % Differences between current evaluator and the rest of evaluators
        eDiffConsensus = eMask - consensusMask;
        eDiffUnion        = eMask - unionMask;
        
        evaluator.FP(e,it) = sum(eDiffUnion(:) > 0.5);
        evaluator.FN(e,it) = sum(eDiffConsensus(:) < -0.5);
        
%         figure(1);
%         im1 = imoverlay(consensusMask,ourDifConsensus < -0.5,'g');
%         im2 = imoverlay(consensusMask,eDiffConsensus < -0.5,'r');
%         imshow(cat(3,[im1(:,:,1), im2(:,:,1)],[im1(:,:,2), im2(:,:,2)],[im1(:,:,3), im2(:,:,3)]))
%         
%         figure(2);
%         im1 = imoverlay(unionMask,ourDifUnion > 0.5,'g');
%         im2 = imoverlay(unionMask,eDiffUnion > 0.5,'r');
%         imshow(cat(3,[im1(:,:,1), im2(:,:,1)],[im1(:,:,2), im2(:,:,2)],[im1(:,:,3), im2(:,:,3)]))        
        
    end
end