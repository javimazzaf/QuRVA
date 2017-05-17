function [branch, sha] = getGitInfo

sha = [];
branch = [];

[~,result] = system('git status --porcelain');
if ~isempty(result)
    error('Not all changes are commited. Commit before continuing.')
end

[~,sha] = system('git rev-parse HEAD');

[~,branch] = system('git rev-parse --abbrev-ref HEAD');

end