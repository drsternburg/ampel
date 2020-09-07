
VPCode = 'VPabaa';

[cnt,mrk] = proc_loadDataset(VPCode,'bci1');

%%
R_move = length(mrk_getTrialMarkers(mrk,{'light move yellow','movement onset'}))/...
         length(mrk_getTrialMarkers(mrk,{'light move yellow'}))
R_idle = length(mrk_getTrialMarkers(mrk,{'light idle yellow','movement onset'}))/...
         length(mrk_getTrialMarkers(mrk,{'light idle yellow'}))