
%%
addpath(fullfile(BTB.PrivateDir,'ampel','functions'))
addpath(fullfile(BTB.PrivateDir,'toolbox_msk'))

%%
subjs_all = {'VPabad','VPabae','VPabaf','VPabag','VPabah','VPabai',...
             'VPabaj','VPabak','VPabal','VPabam','VPaban','VPabao',...
             'VPabap','VPabaq','VPabar','VPabas','VPabat','VPabau',...
             'VPabav','VPabaw','VPabax'};

%% exclude bad data
subjs_bad = {'VPabae',... % bad GND
             'VPabag',... % bad GND and others
             'VPabah',... % bad GND and others
             };
subjs_all = setdiff(subjs_all,subjs_bad);
Ns = length(subjs_all);

%%
%for ii = 1:length(subjs_all)
%    amp_prepareData(subjs_all{ii});
%end