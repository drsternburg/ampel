
function amp_startRecording_noBCI

global opt

bbci = amp_bbci_setup;

pyff('startup'); pause(1)
pyff('init',opt.feedback_name); pause(5);
pyff('set',opt.feedback_params); pause(1);

basename = sprintf('%s_',opt.session_name);
bbci_acquire_bv('close');
pyff('play','basename',basename,'impedances',0);
bbci_apply(bbci);

pyff('stop'); pause(1);
bvr_sendcommand('stoprecording');

fprintf('Finished\n')
