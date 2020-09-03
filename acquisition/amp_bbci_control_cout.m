
function packet = amp_bbci_control_cout(cfy_out,timestamp,event,opt)

if cfy_out >= opt.pred.thresh_pos
    packet = {'i:cl_output',1};
elseif cfy_out <= opt.pred.thresh_neg
    packet = {'i:cl_output',-1};
else
    packet = {'i:cl_output',0};
end