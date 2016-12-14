%% Reads the INI file and assign keys to variables
keys = inifile('config.ini','readall');

for k = 1:size(keys,1)
    assignin('base', keys{k,3}, keys{k,4})
end