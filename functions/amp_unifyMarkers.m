
function mrk = amp_unifyMarkers(mrk,type,cl_target)
% Unifies marker families

switch type
    case 'light'
        cl_orig = {'light move red','light move green','light move yellow',...
                   'light idle red','light idle green','light idle yellow'};
    otherwise
        error('Unknown unification indentifier.')
end
if nargin < 3
    cl_target = type;
end

ci_orig = [];
for ii = 1:length(cl_orig)
    ci_orig = [ci_orig find(strcmp(mrk.className,cl_orig{ii}))];
end

mrk.y(ci_orig(1),:) = sum(mrk.y(ci_orig,:),1);
mrk.y(ci_orig(2:end),:) = [];

mrk.className{ci_orig(1)} = cl_target;
mrk.className(ci_orig(2:end)) = [];