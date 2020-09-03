
function bbci = amp_bbci_setup

global opt

bbci = struct;

bbci.source.acquire_fcn = @bbci_acquire_bv;
bbci.source.min_blocklength = 10;
bbci.source.acquire_param = {struct('fs',opt.acq.fs,'filt_b',opt.acq.filt.b,'filt_a',opt.acq.filt.a)};
%bbci.source.acquire_param = {};

% EEG
bbci.signal(1).source = 1;
bbci.signal(1).proc = {{@online_linearDerivation, opt.acq.A}};

% RP classifier
bbci.feature(1).signal = 1;
bbci.feature(1).proc= {{@proc_baseline,opt.cfy_rp.baseln_len,opt.cfy_rp.baseln_pos}, ...
                       {@proc_jumpingMeans,opt.cfy_rp.ival_fv}};
bbci.feature(1).ival= [opt.cfy_rp.ival_fv(1) opt.cfy_rp.ival_fv(end)];

bbci.classifier(1).feature = 1;
bbci.classifier(1).C = opt.cfy_rp.C;

bbci.control(1).fcn = @amp_bbci_control_button;
bbci.control(1).condition.marker = opt.mrk.def{1,strcmp(opt.mrk.def(2,:),'pedal press')};
bbci.control(1).param = {opt};

bbci.control(2).classifier = 1;
bbci.control(2).fcn = @amp_bbci_control_cout;
bbci.control(2).param = {opt};

bbci.feedback(1).control= 1;
bbci.feedback(1).receiver= 'pyff';
bbci.feedback(2).control= 2;
bbci.feedback(2).receiver= 'pyff';

bbci.quit_condition.marker = -255;

bbci.log.output = 'file';
%bbci.log.filebase = '~/bbci/log/log';
bbci.log.classifier = 1;

