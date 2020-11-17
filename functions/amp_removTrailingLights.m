
function amp_removTrailingLights(subj_code,phase_name)

[cnt,mrk_orig] = proc_loadDataset(subj_code,phase_name);
mrk = amp_unifyMarkers(mrk_orig,'light');

ci = find(strcmp(mrk.className,'light'));
remove = [];
for ii = 1:length(mrk.time)-1
    if find(mrk.y(:,ii))==ci && find(mrk.y(:,ii+1))==ci
        remove = [remove ii+1];
    end
end

if ~isempty(remove)
    mrk = mrk_selectEvents(mrk_orig,'not',remove,'RemoveVoidClasses',0);
    fprintf('%d trailing lights removed.\n',numel(remove))
    filename = [cnt.file '_mrk'];
    save(filename,'mrk')
end