
function [thresh_move,thresh_idle] = amp_findCoutThresh_v3(C)

%%
Nt = length(C);
X = [];
for jj = 1:Nt
    tind = C{jj}.t<=0;
    x = C{jj}.x(tind);
    X = cat(1,X,x');
end

p = prctile(X,[5 95]);
thresh_move = p(1);
thresh_idle = p(2);
