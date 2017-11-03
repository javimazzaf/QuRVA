function [branch, sha] = getGitInfo

[~,result] = system('git status --porcelain');

if ~isempty(result)

    % Ask to commit to git
    answer = inputdlg({'Commit message:'},'Commit before continuing?',1,{'Simple Update'});    

    if isempty(answer)
       error('Cannot continue without commiting') 
    end
    
    % Actually commit all changes
    [~, commMessage] = system(['git add -A && git commit -m "' answer{1} '"']);
    
    % Check if the commit worked
    [~,result] = system('git status --porcelain');
    
    if ~isempty(result)
        error(['Commit error. Cannot continue without commiting.' 10 'Commit error:' 10 commMessage]) 
    end
    
end

[~,sha] = system('git rev-parse HEAD');

[~,branch] = system('git rev-parse --abbrev-ref HEAD');

branch = strip(strip(branch,'right',char(10)),'right',char(13));
sha    = strip(strip(sha,'right',char(10)),'right',char(13));

end