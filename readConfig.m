%% Reads parameters from config.ini
try
    %Loads configuration
    fid = fopen('config.ini');
    
    while ~feof(fid)
        evalin('caller', [fgetl(fid) ';']);
    end
    
    fclose(fid);
    
    %Loads parameters
    fid = fopen('parameters.ini');
    
    while ~feof(fid)
        evalin('caller', [fgetl(fid) ';']);
    end
    
    fclose(fid);
    
catch err
    disp(err)
end
