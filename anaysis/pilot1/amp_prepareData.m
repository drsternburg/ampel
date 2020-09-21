
%%
VPCode = 'VPabac';

%% convert
phase = {'selfpaced','random','bci','bci2','bci3'};
for jj = 1:length(phase)
    proc_convertBVData(VPCode,phase{jj},1);
    proc_regTrainAccelOnsets(VPCode,phase{jj});
end