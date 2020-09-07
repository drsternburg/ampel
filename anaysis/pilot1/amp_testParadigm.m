
VPCode = 'VPabaa';

%% grid plot (self-paced phase)
[cnt,mrk,mnt] = proc_loadDataset(VPCode,'selfpaced');

mrk = mrk_selectClasses(mrk,{'trial start','movement onset'});
epo = proc_segmentation(cnt,mrk,[-1200 0]);
epo = proc_baseline(epo,100,'beginning');
rsq = proc_rSquareSigned(epo);

figure
H = grid_plot(epo,mnt,'PlotStat','sem','ShrinkAxes',[.9 .9]);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);

%% grid plot (random phase)
[cnt,mrk,mnt] = proc_loadDataset(VPCode,'random');

mrk = amp_unifyMarkers(mrk,'light move');
mrk = mrk_selectClasses(mrk,{'light move'});
epo = proc_segmentation(cnt,mrk,[-1200 0]);
epo = proc_baseline(epo,100,'beginning');

figure
H = grid_plot(epo,mnt,'PlotStat','sem','ShrinkAxes',[.9 .9]);

%% grid plot (3 runs of BCI phase)
for jj = 1:3
    
    [cnt,mrk,mnt] = proc_loadDataset(VPCode,sprintf('bci%d',jj));
    
    mrk = amp_unifyMarkers(mrk,'light both');
    mrk = mrk_selectClasses(mrk,{'light move','light idle'});
    epo = proc_segmentation(cnt,mrk,[-1200 0]);
    epo = proc_baseline(epo,100,'beginning');
    rsq = proc_rSquareSigned(epo);
    
    figure
    H = grid_plot(epo,mnt,'PlotStat','sem','ShrinkAxes',[.9 .9]);
    grid_addBars(rsq,'HScale',H.scale,'Height',1/7);
    
end

%% interruption times during BCI phase
IT = [];
G1 = [];
G2 = [];
light = {'light move','light idle'};
for jj = 1:3
    
    [cnt,mrk,mnt] = proc_loadDataset(VPCode,sprintf('bci%d',jj));
    mrk = amp_unifyMarkers(mrk,'light both');
    
    for kk = 1:2
        trial = mrk_getTrialMarkers(mrk,light{kk});
        mrk2 = mrk_selectEvents(mrk,[trial{:}]);
        mrk2 = mrk_selectClasses(mrk2,{'trial start',light{kk}});
        IT = cat(1,IT,(mrk2.time(logical(mrk2.y(2,:)))-mrk2.time(logical(mrk2.y(1,:))))'/1000);
        Nt = length(mrk2.time)/2;
        G1 = cat(1,G1,repmat({sprintf('BCI%d',jj)},Nt,1));
        G2 = cat(1,G2,repmat(light(kk),Nt,1));
    end
    
end

figure
boxplot(IT,{G1,G2},'orientation','hori','colorgroup',{G2},'whisker',2)















