try
    readConfig
    outputFolder = fullfile(masterFolder, 'Optimization');
    mkdir(outputFolder)
    % Backup parameters
    copyfile('config.ini','config.ini.bak','f');
    
    inifile('config.ini','write',{'','','doTufts',1})
    inifile('config.ini','write',{'','','doVasculature',0})
    inifile('config.ini','write',{'','','doSaveImages',0})
    
    paramName = 'tufts.thick.DilatingRadiusDivisor';
    N      = 6;
    minVal = 4000;
    maxVal = 9000;
    parValues = ((1:N)-1)/(N-1) * (maxVal-minVal) + minVal;
    
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
        
        allTP(p) = sum(TP);
        allFP(p) = sum(FP);
        allFN(p) = sum(FN);
        
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

