
function T = amp_analyzeTrials(subj_code)

Y = [];
for ii = 1:length(subj_code)
    
    [~,mrk] = proc_loadDataset(subj_code{ii},'bci');
    trial = mrk_getTrialMarkers(mrk);
    
    Nt = length(trial);
    for jj = 1:Nt
        
        mrk2 = mrk_selectEvents(mrk,trial{jj});
        ci = strncmp(mrk2.className,'light',5);
        if ~any(ci)
            continue
        end
        thislight = mrk2.className{ci};
        
        if contains(thislight,'green')
            color = 1;
        elseif contains(thislight,'red')
            color = 2;
        elseif contains(thislight,'yellow')
            color = 3;
        end
        
        if contains(thislight,'random')
            trigger = 1;
        elseif contains(thislight,'idle')
            trigger = 2;
        elseif contains(thislight,'move')
            trigger = 3;
        end
        
        mrk_lt = mrk_selectClasses(mrk2,thislight);
        mrk_ts = mrk_selectClasses(mrk2,'trial start');
        CT = mrk_lt.time-mrk_ts.time;
        
        if any(strcmp(mrk2.className,'movement onset'))
            mrk_mo = mrk_selectClasses(mrk2,'movement onset');
            RT = mrk_lt.time-mrk_mo.time;
            movement = 1;
        else
            RT = NaN;
            movement = 0;
        end
        
        Y = cat(1,Y,[ii jj color trigger CT movement RT]);
        
    end
    
end

VariableNames = {'Subj','Trial','Color','Trigger','CT','Move','RT'};
T = array2table(Y);
T.Properties.VariableNames = VariableNames;













