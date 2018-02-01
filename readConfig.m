%% Reads parameters from config.ini
try
    fid = fopen('config.ini');
    while ~feof(fid)
        evalin('caller', [fgetl(fid) ';']);
    end
    fclose(fid);
    
    fid = fopen('parameters.ini');
    while ~feof(fid)
        evalin('caller', [fgetl(fid) ';']);
    end
    fclose(fid);
    
catch err
    disp(err)
end

% HARDCODED PARAMETERS FOR COMPILED RELEASE
% doTufts = true;
% doVasculature = true;
% doSaveImages = true;
% 
% computeMaskAndCenterAutomatically = true;
% 
% vascNet.ThreshNeighborSize = [51 51];
% vascNet.OpeningSize = 500;
% vascNet.DilatingRadius = 2;
% 
% tufts.resampleScale = 0.25; 
% tufts.denoiseFilterSize = 0.5;
% tufts.blockSizeFraction = 1 / 180;
% tufts.blocksInMaskPercentage = 25;
% tufts.lbpTolPercentage = 5;
% tufts.classCost.ClassNames = [0 1];
% tufts.classCost.ClassificationCosts = [0 1;1 0];
% 
% consensus.reqVotes = 4;