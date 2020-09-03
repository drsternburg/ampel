
amp_setupEnvironment;
global opt

%% Setup participant
acq_makeDataFolder;

%% Block 1: self-paced task
opt.feedback_params.mode = int16(1);
opt.feedback_params.listen_to_keyboard = int16(0);
opt.feedback_params.end_pause_counter_type = int16(1); % pedal presses
opt.feedback_params.end_after_x_events = int16(50);
opt.feedback_params.pause_every_x_events = int16(25);
amp_startRecording('selfpaced')

%% Block 2: traffic-light (random)
opt.feedback_params.mode = int16(2);
opt.feedback_params.listen_to_keyboard = int16(0);
opt.feedback_params.end_pause_counter_type = int16(3); % idle lights
opt.feedback_params.end_after_x_events = int16(50);
opt.feedback_params.pause_every_x_events = int16(25);
opt.feedback_params.cue_waittime = amp_drawCueTimes(100,[4000 10000]);
opt.feedback_params.trial_assignment = int16(amp_drawTrialAssignments(100,[1/3 1/3 1/3 0 0 0]));
amp_startRecording('random')

%% Setup BCI
proc_convertBVData(BTB.Tp.Code,'selfpaced',0);
proc_convertBVData(BTB.Tp.Code,'random',0);
proc_regTrainAccelOnsets(BTB.Tp.Code,'selfpaced');

amp_setupOnlineClassifier(BTB.Tp.Code);

save([fullfile(BTB.Tp.Dir,opt.session_name) '_' BTB.Tp.Code '_opt'],'opt')

%% Block 3: traffic-light (BCI)
opt.feedback_params.mode = int16(3);
opt.feedback_params.listen_to_keyboard = int16(0);
opt.feedback_params.end_pause_counter_type = int16(2); % move lights
opt.feedback_params.end_after_x_events = int16(40);
opt.feedback_params.pause_every_x_events = int16(40);
opt.feedback_params.trial_assignment = int16(amp_drawTrialAssignments(250,ones(1,6)/6));
amp_startRecording('bci')
