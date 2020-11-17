
function amp_prepareData(subj_code)

phase = {'selfpaced','random','bci'};

for jj = 1:length(phase)
    proc_convertBVData(subj_code,phase{jj},1,1);
    if jj==1
        proc_regTrainAccelOnsets(subj_code,phase{jj});
    else
        if jj==3
            amp_removTrailingLights(subj_code,phase{jj});
        end
        amp_regTrainAccelOnsets_cue(subj_code,phase{jj});
    end
end
