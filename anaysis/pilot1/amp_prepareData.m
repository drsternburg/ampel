
amp_setupEnvironment;

%%
VPCode = 'VPabaa';

%% convert
phase = {'selfpaced','random','bci1','bci2','bci3'};
for jj = 1:length(phase)
    proc_convertBVData(VPCode,phase{jj},1);
    proc_regTrainAccelOnsets(VPCode,phase{jj});
end