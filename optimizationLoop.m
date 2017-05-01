try
    readConfig
    outputFolder = fullfile(masterFolder, 'Optimization');
    mkdir(outputFolder)
    % Backup parameters
    copyfile('parameters.ini','parameters.ini.bak','f');
    
    inifile('parameters.ini','write',{'','','doTufts',1})
    inifile('parameters.ini','write',{'','','doVasculature',0})
    inifile('parameters.ini','write',{'','','doSaveImages',0})
    
    paramName = 'tufts.openingArea';
%     N      = 7;
%     minVal = 10;
%     maxVal = 30;
%     parValues = ((1:N)-1)/(N-1) * (maxVal-minVal) + minVal;
%     parValues = [10 15 20 25 30 40 50 75 100];
    parValues = [30 50 70 100 200 300 400 500];
    N         = numel(parValues);
    
    scoresPix = NaN(1,N);
    scoresObj = NaN(1,N);
    
    evScoresPix = NaN(12,N);
    evScoresObj = NaN(12,N);    
    
    for p = 1:N
        disp(['Iteration ' num2str(p) ' of ' num2str(N)])
        
        % Compute parameters
        parValue = parValues(p);
        
        % Set parameters
        inifile('parameters.ini','write',{'','',paramName,parValue})
        
        % Compute tufts
        processFolder;
        
        % measure performance
        [scorePix, scoreObj, evScorePix, evScoreObj] = computeScore;
        
        [params,~,~] = inifile('parameters.ini','readall');
        save(fullfile(masterFolder, 'Optimization',[paramName '=' num2str(parValue) '.mat']),'scorePix', 'scoreObj','evScorePix', 'evScoreObj','params')
        
        scoresPix(p) = scorePix;
        scoresObj(p) = scoreObj;
        
        evScoresPix(:,p) = evScorePix;
        evScoresObj(:,p) = evScoreObj;        
        
    end
    
%     table()
    
    save(fullfile(masterFolder, 'Optimization','optimizationAll.mat'),'scoresPix','scoresObj','paramName','evScoresPix','evScoresObj','parValues');
    
    set(0,'DefaultFigureWindowStyle','docked')
    figure(1); plot(parValues,scoresPix), xlabel(paramName), ylabel('scoresPix'), hold on
    plot(parValues,evScoresPix(1:6,:)','-g')
    plot(parValues,evScoresPix(7:12,:)','-r')
    print(1, fullfile(masterFolder, 'Optimization','scoresPix.png'),'-dpng')
    figure(2); plot(parValues,scoresObj), xlabel(paramName), ylabel('scoresObj'), hold on
    plot(parValues,evScoresObj(1:6,:)','-g')
    plot(parValues,evScoresObj(7:12,:)','-r')
    print(2, fullfile(masterFolder, 'Optimization','scoresObj.png'),'-dpng')
    set(0,'DefaultFigureWindowStyle','normal')
    
    % Restore parameters.ini
    movefile('parameters.ini.bak','parameters.ini','f');
    
catch err
    disp(err)
    % Restore parameters.ini
    movefile('parameters.ini.bak','parameters.ini','f');
end

