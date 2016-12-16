%% Reads parameters from config.ini
try
    fid = fopen('config.ini');
    
    while ~feof(fid)
        evalin('caller', [fgetl(fid) ';']);
    end
    
    fclose(fid);
catch err
    disp(err)
end
