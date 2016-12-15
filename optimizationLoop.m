try
    readConfig
    outputFolder = fullfile(masterFolder, 'Optimization');
    mkdir(outputFolder)
    % Backup parameters
    copyfile('config.ini','config.ini.bak','f');
    
    inifile('config.ini','write',{'','','doTufts',1})
    inifile('config.ini','write',{'','','doVasculature',0})
    inifile('config.ini','write',{'','','doSaveImages',0})
    
    allTP = NaN(1,3);
    allFP = NaN(1,3);
    allFN = NaN(1,3);
    
    for ms = 1:1
        for bs = 1:3
        % Compute parameters
        medFilterSize = 30 + 10 * (ms-1);
        brightSensitivity = (bs-1)/2 * 0.4 + 0.3;
        
        % Set parameters
        inifile('config.ini','write',{'','','tufts.thick.medFilterSize',medFilterSize})
        inifile('config.ini','write',{'','','tufts.bright.binSensitivity',brightSensitivity})
        
        % Compute tufts
        processFolder;
        
        % measure performance
        [FP, FN, TP] = measureTuftSegmentationPerformance;
        
        fg = figure;
        plot(TP,'g'), hold on
        plot(FP,'r')
        plot(FN,'b')
        legend({'TP';'FP';'FN'})
        
        [params,~,~] = inifile('config.ini','readall');
        save(fullfile(masterFolder, 'Optimization',['optimization_MedianSize=' num2str(medFilterSize) '_brightSensitivity=' num2str(brightSensitivity) '.mat']),'TP','FP','FN','params')
        
        allTP(ms,bs) = sum(TP);
        allFP(ms,bs) = sum(FP);
        allFN(ms,bs) = sum(FN);
        
        close(fg)
        
        end
        
    end
    
    save(fullfile(masterFolder, 'Optimization','optimizationAll.mat'),'allTP','allFP','allFN');
    
    % Restore config.ini
    movefile('config.ini.bak','config.ini','f');
    
catch err
    disp(err)
    % Restore config.ini
    movefile('config.ini.bak','config.ini','f');
end

