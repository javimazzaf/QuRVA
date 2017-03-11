function optimizationLoop

% To make sure the config files stay as before
cleanupObj = onCleanup(@finalClean);

try
    readConfig
    outputFolder = fullfile(masterFolder, 'Optimization');
    mkdir(outputFolder)
    % Backup parameters
    copyfile('parameters.ini','parameters.ini.bak','f');
    
    inifile('parameters.ini','write',{'','','doTufts',1})
    inifile('parameters.ini','write',{'','','doVasculature',0})
    inifile('parameters.ini','write',{'','','doSaveImages',0})
    
    paramName = 'tufts.sensitivityFactor';
    N      = 21;
    minVal = 0.5;
    maxVal = 1;
    parValues = ((1:N)-1)/(N-1) * (maxVal-minVal) + minVal;
%     parValues = [0.1 0.2 0.3 0.4 0.5 0.6 0.7];
    
    allTP = NaN(1,N);
    allFP = NaN(1,N);
    allFN = NaN(1,N);
    
    for p = 1:N
        disp(['Iteration ' num2str(p) ' of ' num2str(N)])
        
        % Compute parameters
        parValue = parValues(p);
        
        % Set parameters
        inifile('parameters.ini','write',{'','',paramName,parValue})
        
        % Compute tufts
        processFolder;
        
        % measure performance
        [FP, FN, TP] = measureTuftSegmentationPerformance;
        
        [params,~,~] = inifile('parameters.ini','readall');
        save(fullfile(masterFolder, 'Optimization',[paramName '=' num2str(parValue) '.mat']),'TP','FP','FN','params')
        
        allTP(p) = sum(TP);
        allFP(p) = sum(FP);
        allFN(p) = sum(FN);
        
    end
    
    save(fullfile(masterFolder, 'Optimization','optimizationAll.mat'),'allTP','allFP','allFN','paramName','parValues');
    
catch err
    disp(err)
    % Restore parameters.ini
    movefile('parameters.ini.bak','parameters.ini','f');
end


function finalClean
    % Restore parameters.ini
    movefile('parameters.ini.bak','parameters.ini','f');
end

end

