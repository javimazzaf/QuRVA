try
    % Backup parameters
    copyfile('config.ini','config.ini.bak','f');
    
    inifile('config.ini','write',{'','','doTufts',1})
    inifile('config.ini','write',{'','','doVasculature',0})
    inifile('config.ini','write',{'','','doSaveImages',0})
    
    for l = 1:3
        % Compute parameters
        medFilterSize = 50 + 5 * (l-1);
        
        % Set parameters
        inifile('config.ini','write',{'','','tufts.thick.medFilterSize',medFilterSize})
        
        % Compute tufts
        processFolder;
        
    end
    
    % Restore config.ini
    movefile('config.ini.bak','config.ini','f');
    
catch
    % Restore config.ini
    movefile('config.ini.bak','config.ini','f');
end

