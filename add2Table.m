function add2Table(masterFolder,table2Add)
% Adds table2Add at the end of the table in the last csv file found in the
% Reports Folder. If there is an error, it creates a new file with today's
% date.

% *************************************************************************
% Copyright (C) 2018 Javier Mazzaferri and Santiago Costantino 
% <javier.mazzaferri@gmail.com>
% <santiago.costantino@umontreal.ca>
% Hopital Maisonneuve-Rosemont, 
% Centre de Recherche
% www.biophotonics.ca
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% *************************************************************************

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