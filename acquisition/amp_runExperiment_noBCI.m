
amp_setupEnvironment;
global opt

opt.session_name = 'Ampel_noBCI';

opt.feedback_name = 'TrafficLight_decide';
opt.feedback_params.mode = int16(2);
opt.feedback_params.listen_to_keyboard = int16(0);
opt.feedback_params.end_pause_counter_type = int16(5); % trials
opt.feedback_params.end_after_x_events = int16(150);
opt.feedback_params.pause_every_x_events = int16(50);
opt.feedback_params.cue_waittime = amp_drawCueTimes(200,[2000 8000]);

%% setup participant
acq_makeDataFolder;

%% start feedback 1
opt.feedback_params.trial_assignment = int16(amp_drawTrialAssignments(200,[0 0 0 1/3 1/3 1/3]));
amp_startRecording_noBCI

%% start feedback 2
opt.feedback_params.trial_assignment = int16(amp_drawTrialAssignments(200,[0 0 0 0 0 1]));
amp_startRecording_noBCI
