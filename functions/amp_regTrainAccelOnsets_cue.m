
function mrk = amp_regTrainAccelOnsets_cue(subj_code,phase_name)

global opt BTB

[cnt,mrk_orig] = proc_loadDataset(subj_code,phase_name);
mrk_orig = mrk_selectClasses(mrk_orig,'not','movement onset');

must_contain = 'pedal press';
trial = mrk_getTrialMarkers(mrk_orig,must_contain);
mrk_train = mrk_selectEvents(mrk_orig,[trial{:}]);
mrk_train = mrk_selectClasses(mrk_train,{'trial start','pedal press'});

mrk_test = amp_unifyMarkers(mrk_orig,'light');
must_contain = 'light';
trial = mrk_getTrialMarkers(mrk_test,must_contain);
mrk_test = mrk_selectEvents(mrk_test,[trial{:}]);
mrk_test = mrk_selectClasses(mrk_test,{'light','trial end'});

cnt = proc_selectChannels(cnt,'M*');
dt = 1000/cnt.fs;

%% train online detector
mrk_train.time(logical(mrk_train.y(1,:))) = mrk_train.time(logical(mrk_train.y(1,:)))+opt.cfy_acc.offset;
fv = proc_segmentation(cnt,mrk_train,opt.cfy_acc.ival_fv);
fv = proc_variance(fv);
fv = proc_logarithm(fv);
fv = proc_flaten(fv);
loss = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
fprintf('xval accuracy: %3.3f%%\n',(1-loss)*100)
C = train_RLDAshrink(fv.x,fv.y);

%% find single-trial onsets with cross-validated detector
Nt = sum(mrk_test.y(1,:));
i_trial = reshape(1:Nt*2,2,Nt);

t_onset = nan(Nt,1);
for jj = 1:Nt
    
    mrk_trial = mrk_selectEvents(mrk_test,i_trial(:,jj));
    T = [mrk_trial.time(1) mrk_trial.time(2)];
    t = T(1);
    while t <=T(2)
        fv = proc_segmentation(cnt,t,opt.cfy_acc.ival_fv);
        fv = proc_variance(fv);
        fv = proc_logarithm(fv);
        fv = proc_flaten(fv);
        cout = apply_separatingHyperplane(C,fv.x(:));
        if cout>0
            t_onset(jj) = t;
            break
        end
        t = t+dt;
    end
    
end

%% assign registered movement onsets
mrk_mo.time = t_onset;
mrk_mo.y = ones(1,length(t_onset));
mrk_mo.className = {'movement onset'};
mrk = mrk_mergeMarkers(mrk_orig,mrk_mo);
mrk = mrk_sortChronologically(mrk);

%% save new marker struct
ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},6);
ds_name = ds_list(ds_idx).name;
filename = fullfile(ds_name,sprintf('%s_%s_%s',opt.session_name,phase_name,subj_code));
filename = fullfile(BTB.MatDir,[filename '_mrk']);
save(filename,'mrk')













