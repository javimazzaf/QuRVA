%% Reads the INI file and assign keys to variables
if exist('config.ini','file')
    keys = inifile('config.ini','readall');
    
    for k = 1:size(keys,1)
        assignin('caller', keys{k,3}, keys{k,4})
    end
end