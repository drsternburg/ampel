
function mrk = amp_unifyMarkers(mrk,type)
% Unifies marker families

switch type
    case 'light'
        cl_orig = {'light move red','light move green','light move yellow',...
                   'light idle red','light idle green','light idle yellow',...
                   'light random red','light random green','light random yellow'};
    case 'light idle'
        cl_orig = {'light idle red','light idle green','light idle yellow'};
    case 'light move'
        cl_orig = {'light move red','light move green','light move yellow'};
    case 'light random'
        cl_orig = {'light random red','light random green','light random yellow'};
    case 'light all'
        mrk = amp_unifyMarkers(mrk,'light move');
        mrk = amp_unifyMarkers(mrk,'light idle');
        mrk = amp_unifyMarkers(mrk,'light random');
        return
    otherwise
        error('Unknown unification indentifier.')
end

cl_target = type;

ci_orig = [];
for ii = 1:length(cl_orig)
    ci_orig = [ci_orig find(strcmp(mrk.className,cl_orig{ii}))];
end

mrk.y(ci_orig(1),:) = sum(mrk.y(ci_orig,:),1);
mrk.y(ci_orig(2:end),:) = [];

mrk.className{ci_orig(1)} = cl_target;
mrk.className(ci_orig(2:end)) = [];