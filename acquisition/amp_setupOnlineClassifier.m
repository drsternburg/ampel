
function amp_setupOnlineClassifier(subj_code)

global opt
warning off

%% load and prepare self-paced data
[cnt,mrk,mnt] = proc_loadDataset(subj_code,'selfpaced');
%%%
cnt = proc_selectChannels(cnt,'not',{'C2','P3'});
%%%
cnt = proc_commonAverageReference(cnt); % because it was converded without CAR
cnt = proc_selectChannels(cnt,opt.cfy_rp.clab_base);
must_contain = 'movement onset';
trial_mrk = mrk_getTrialMarkers(mrk,must_contain);
mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);

%% Exclude too short waiting times
mrk_mo = mrk_selectClasses(mrk,'movement onset');
mrk_ts = mrk_selectClasses(mrk,'trial start');
t_ts2mo = mrk_mo.time - mrk_ts.time;
ind_valid = t_ts2mo>=-opt.cfy_rp.fv_window(1);
trial_mrk = mrk_getTrialMarkers(mrk);
mrk = mrk_selectEvents(mrk,[trial_mrk{ind_valid}]);
t_ts2mo = t_ts2mo(ind_valid);

%% get amplitudes
mrk_ = mrk_selectClasses(mrk,{'trial start','movement onset'});
epo = proc_segmentation(cnt,mrk_,opt.cfy_rp.fv_window);
epo = proc_baseline(epo,opt.cfy_rp.baseln_len,opt.cfy_rp.baseln_pos);
rsq = proc_rSquareSigned(epo);
amp = proc_meanAcrossTime(epo,opt.cfy_rp.ival_amp);

%% visualize ERPs
figure
H = grid_plot(epo,mnt,'PlotStat','sem');%,'ShrinkAxes',[.9 .9]);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);

%% channel selection
if verLessThan('matlab', '8.4')
    [~,pval1] = ttest(squeeze(amp.x(1,:,logical(amp.y(2,:))))',0,.05,'left'); % RP amplitudes must be smaller than zero
    [~,pval2] = ttest2(squeeze(amp.x(1,:,logical(amp.y(2,:))))',...
        squeeze(amp.x(1,:,logical(amp.y(1,:))))',.05,...
        'left'); % RP amplitudes must be smaller than No-RP amplitudes
else
    [~,pval1] = ttest(squeeze(amp.x(1,:,logical(amp.y(2,:))))',0,'tail','left'); % RP amplitudes must be smaller than zero
    [~,pval2] = ttest2(squeeze(amp.x(1,:,logical(amp.y(2,:))))',...
        squeeze(amp.x(1,:,logical(amp.y(1,:))))',...
        'tail','left'); % RP amplitudes must be smaller than No-RP amplitudes
end
chanind_sel = pval1<.05&pval2<.05;
opt.cfy_rp.clab = amp.clab(chanind_sel);
fprintf('\nSelected channels:\n')
fprintf('%s\n',opt.cfy_rp.clab{:})

%% define online filter
% reload data
cnt = proc_loadDataset(subj_code,'selfpaced');

% define online spatial filter
Nc = length(cnt.clab);
rc = util_scalpChannels(cnt.clab);
rrc = util_chanind(cnt.clab,opt.cfy_rp.clab);
opt.acq.A = eye(Nc,Nc);
opt.acq.A(rc,rrc) = opt.acq.A(rc,rrc) - 1/length(rc);
opt.acq.A = opt.acq.A(:,rrc);

% apply online spatial filter
cnt = proc_linearDerivation(cnt,opt.acq.A);

%% train classifier and assess accuracy
mrk_ = mrk_selectClasses(mrk,{'trial start','movement onset'});
fv = proc_segmentation(cnt,mrk_,opt.cfy_rp.fv_window);
fv = proc_baseline(fv,opt.cfy_rp.baseln_len,opt.cfy_rp.baseln_pos);
fv = proc_jumpingMeans(fv,opt.cfy_rp.ival_fv);
fv = proc_flaten(fv);

opt.cfy_rp.C = train_RLDAshrink(fv.x,fv.y);

loss = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
fprintf('\nClassification accuracy: %2.1f%%\n',100*(1-loss))

%% load and prepare 'random' data
[cnt,mrk] = proc_loadDataset(subj_code,'random');
cnt = proc_linearDerivation(cnt,opt.acq.A);
mrk = amp_unifyMarkers(mrk,'light');
must_contain = 'light';
trial_mrk = mrk_getTrialMarkers(mrk,must_contain);
mrk = mrk_selectEvents(mrk,[trial_mrk{:}]);

%% sliding classifier output
mrk_ = mrk_selectClasses(mrk,{'trial start','light','trial end'});
opt2 = struct('ivals_fv',opt.cfy_rp.ival_fv,'baseln_len',opt.cfy_rp.baseln_len,'baseln_pos',opt.cfy_rp.baseln_pos);
cout = proc_slidingClassification(cnt,mrk_,opt2,opt.cfy_rp.C);

%% define threshold
%[thresh_pos,thresh_neg] = amp_findCoutThresh(cout,opt.pred.target_isi);
[thresh_pos,thresh_neg] = amp_findCoutThresh_v2(cout,opt.pred.target_isi);
%[thresh_pos,thresh_neg] = amp_findCoutThresh_v3(cout);
opt.pred.thresh_pos = thresh_pos;
opt.pred.thresh_neg = thresh_neg;





















