% Adds table2Add at the end of the table in the last csv file found in the
% Reports Folder. If there is an error, it creates a new file with today's
% date.
function add2Table(masterFolder,table2Add)
% Takes the last file
tablePath = fullfile(masterFolder, 'Reports');
tableFiles = dir(fullfile(tablePath,'*.csv'));
tableFiles = sort({tableFiles(:).name});

if isempty(tableFiles), tableFileName = fullfile(masterFolder, 'Reports', 'AnalysisResult.csv');
else,                   tableFileName = fullfile(masterFolder, 'Reports', tableFiles{end});
end

oldTable = [];

if exist(tableFileName,'file')
    try
        oldTable = readtable(tableFileName,'Delimiter','\t');
    catch
        [tablePath,fname,fext] = fileparts(tableFileName);
        newFname = [fname datestr(now,'yyyymmdd_HHMMSS') fext];
        disp(['Failed opening ' fname '.' fext '. Creating new file: ' newFname]);
        
        tableFileName = fullfile(tablePath,newFname);
    end
end

writetable([oldTable;table2Add],tableFileName,'Delimiter','\t')
end