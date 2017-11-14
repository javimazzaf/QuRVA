function outPath = getExecutablePath

if ~isdeployed
    fullpath = mfilename('fullpath');
    [outPath,~,~] = fileparts(fullpath);
    outPath = [strtrim(outPath) filesep];
    return
end

try
    
    if isunix
        [~, fullPath] = system('ps -ef | grep [t]estPath.app | awk ''{print $8}''');
        outPath = char(regexpi(fullPath, '.*(<?\/)', 'match'));
    elseif ispc
        [~, outPath] = system('path');
        outPath = char(regexpi(outPath, 'PATH=(.*?);', 'tokens', 'once'));
        outPath = [strtrim(outPath) filesep];
    end
    
catch
    outPath = '';
end

end