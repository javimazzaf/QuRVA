function AnalysisResult = openReport(baseDir)

% Load all csv files in a single table
tablePath  = fullfile(baseDir, 'Reports');
tableFiles = dir(fullfile(tablePath,'*.csv'));
tableFiles = sort({tableFiles(:).name});

AnalysisResult = table;

for tf = 1:numel(tableFiles)
    
    try    
        thisTable = readtable(fullfile(tablePath,tableFiles{tf}));
    catch
        warning('Could not read: %s. Skipped file.', fullfile(tablePath,tableFiles{tf}))
        continue
    end
    
    try
        AnalysisResult = [AnalysisResult;thisTable];
    catch
        warning('Could not append: %s. Skipped file', fullfile(tablePath,tableFiles{tf}))
        continue
    end
    
end

end
%% Clear temporary variables
% clearvars data raw cellVectors;