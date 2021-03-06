
global BTB opt
opt = struct;

opt.session_name = 'Ampel';
opt.feedback_name = 'TrafficLight_decide';

%%
if ispc
    BTB.PrivateDir = 'C:\bbci';
end
addpath(fullfile(BTB.PrivateDir,'toolbox_msk'))
addpath(fullfile(BTB.PrivateDir,'ampel','acquisition'))
addpath(fullfile(BTB.PrivateDir,'ampel','functions'))

%%
BTB.Acq.Geometry = [1281 1 1280 998];
BTB.Acq.Dir = fullfile(BTB.PrivateDir,'ampel','acquisition');
BTB.Acq.IoAddr = hex2dec('0378');
BTB.PyffDir = 'C:\bbci\pyff\src';
BTB.Acq.Prefix = 'ab';
BTB.Acq.StartLetter = 'a';
BTB.FigPos = [1 1];

%% parameters for raw data
opt.acq.orig_fs = 1000;
Wps = [42 49]/opt.acq.orig_fs*2;
[n,Ws] = cheb2ord(Wps(1),Wps(2),3,40);
[opt.acq.filt.b,opt.acq.filt.a] = cheby2(n,50,Ws);
opt.acq.fs = 100;
opt.acq.clab = {
                'F3','F1','Fz','F2','F4'...
                'FC5','FC3','FC1','FC2','FC4','FC6',...
                'C5','C3','C1','Cz','C2','C4','C6',...
                'CP5','CP3','CP1','CPz','CP2','CP4','CP6',...
                'P3','P1','Pz','P2','P4',...
                'Mx','My','Mz'
                };
% opt.acq.clab = {
%                 'F1','Fz','F2',...
%                 'FC3','FC1','FC2','FC4',...
%                 'C3','C1','Cz','C2','C4',...
%                 'CP3','CP1','CPz','CP2','CP4',...
%                 'P1','Pz','P2',...
%                 'Mx','My','Mz'
%                 };
% opt.acq.clab = {'Fp1','Fp2',...
%                 'AF7','AF3','AFz','AF4','AF8',...
%                 'F7','F5','F3','F1','Fz','F2','F4','F6','F8',...
%                 'FT9','FT7','FC5','FC3','FC1','FC2','FC4','FC6','FT8','FT10'...
%                 'T7','C5','C3','C1','Cz','C2','C4','C6','T8',...
%                 'TP9','TP7','CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','TP10'...
%                 'P7','P5','P3','P1','Pz','P2','P4','P6','P8',...
%                 'PO7','PO3','POz','PO4','PO8',...
%                 'O1','Oz','O2',...
%                 'Mx','My','Mz'
%                 };

%% markers
opt.mrk.def = { 64 'pedal press';...
               -30 'trial end'; ...
               -10 'trial start';...
               -21 'light random red';...
               -22 'light random green';...
               -23 'light random yellow';...
               -24 'light move red';...
               -25 'light move green';...
               -26 'light move yellow';...
               -27 'light idle red';...
               -28 'light idle green';...
               -29 'light idle yellow';...
               }';

%% parameters for classification
opt.cfy_rp.clab_base = {'F1','Fz','F2',...
                        'FC3','FC1','FC2','FC4'...
                        'C3','C1','Cz','C2','C4'...
                        'CP3','CP1','CPz','CP2','CP4'...
                        'P1','Pz','P2'};
opt.cfy_rp.clab = opt.cfy_rp.clab_base;

Nc = length(opt.acq.clab);
rc = util_scalpChannels(opt.acq.clab);
rrc = util_chanind(opt.acq.clab,opt.cfy_rp.clab);
opt.acq.A = eye(Nc,Nc);
opt.acq.A(rc,rrc) = opt.acq.A(rc,rrc) - 1/length(rc);
opt.acq.A = opt.acq.A(:,rrc);

opt.cfy_rp.baseln_len = 200;
opt.cfy_rp.baseln_pos = 'beginning';
opt.cfy_rp.ival_fv = [-1400 -1200;
                      -1200 -1000;
                      -1000  -800;
                       -800  -600;
                       -600  -400;
                       -400  -200];
opt.cfy_rp.fv_window = [opt.cfy_rp.ival_fv(1) opt.cfy_rp.ival_fv(end)];

opt.cfy_rp.ival_amp = [-200 0];

% fake classifiers of phase 1:
opt.cfy_rp.C.gamma = randn;
opt.cfy_rp.C.b = randn;
opt.cfy_rp.C.w = randn(size(opt.cfy_rp.ival_fv,1)*length(opt.cfy_rp.clab),1);

opt.cfy_acc.clab = {'M*'};
opt.cfy_acc.ival_fv = [-200 0];
opt.cfy_acc.offset = 500;

%% parameters for finding optimal prediction threshold
opt.pred.thresh_pos = 1; % for the fake classifier of phase 1
opt.pred.thresh_neg = -1; % for the fake classifier of phase 1
opt.pred.target_isi = 3; % seconds







