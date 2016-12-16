try
    readConfig
    outputFolder = fullfile(masterFolder, 'Optimization');
    mkdir(outputFolder)
    % Backup parameters
    copyfile('config.ini','config.ini.bak','f');
    
    inifile('config.ini','write',{'','','doTufts',1})
    inifile('config.ini','write',{'','','doVasculature',0})
    inifile('config.ini','write',{'','','doSaveImages',0})
    
    N = 3;
    paramName = 'tufts.thick.DilatingRadiusDivisor';
    parValues = ((1:N)-1)/(N-1) * 1000 + 500;
    
    allTP = NaN(1,N);
    allFP = NaN(1,N);
    allFN = NaN(1,N);
    
    for p = 1:N
        disp(['Iteration ' num2str(p) ' of ' num2str(N)])
        
        % Compute parameters
        parValue = parValues(p);
        
        % Set parameters
        inifile('config.ini','write',{'','',paramName,parValue})
        
        % Compute tufts
        processFolder;
        
        % measure performance
        [FP, FN, TP] = measureTuftSegmentationPerformance;
        
        [params,~,~] = inifile('config.ini','readall');
        save(fullfile(masterFolder, 'Optimization',[paramName '=' num2str(parValue) '.mat']),'TP','FP','FN','params')
        
        allTP(ms,p) = sum(TP);
        allFP(ms,p) = sum(FP);
        allFN(ms,p) = sum(FN);
        
        close(fg)
        
    end
    
%     table()
    
    save(fullfile(masterFolder, 'Optimization','optimizationAll.mat'),'allTP','allFP','allFN','paramName','parValues');
    
    % Restore config.ini
    movefile('config.ini.bak','config.ini','f');
    
catch err
    disp(err)
    % Restore config.ini
    movefile('config.ini.bak','config.ini','f');
end

