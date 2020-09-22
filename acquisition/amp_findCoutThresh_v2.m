
function [thresh_move,thresh_idle] = amp_findCoutThresh_v2(C,target_ISI)

%%
Nt = length(C);
X = [];
for jj = 1:Nt
    tind = C{jj}.t<=0;
    x = C{jj}.x(tind);
    X = cat(1,X,x');
end

Nth = 100;
thresh = linspace(prctile(X,1),prctile(X,99),Nth);

Ncr = nan(Nth,2);
minp = 7;
for kk = 1:Nth
    
    ind1 = find(X<thresh(kk),1,'first');
    ind2 = find(X<thresh(kk),1,'last');
    x = X(ind1:ind2);
    df = diff(sign(x-thresh(kk)));
    t1 = find(df==2);
    t2 = find(df==-2);
    if numel(t1)==numel(t2)
        Ncr(kk,1) = sum((t2-t1)>minp);
    end
    
    ind1 = find(X>thresh(kk),1,'first');
    ind2 = find(X>thresh(kk),1,'last');
    x = X(ind1:ind2);
    df = diff(sign(x-thresh(kk)));
    t1 = find(df==2);
    t2 = find(df==-2);
    if numel(t1)==numel(t2)
       Ncr(kk,2) = sum((t1-t2)>minp);
    end
    
end

Ttot = length(X)/100;
R = Ttot./Ncr;

figure
plot(thresh,R)

ind = thresh>0;
thr = thresh(ind);
thr = thr(find(diff(sign(R(ind,1) - target_ISI))==2));
thresh_move = thr(1);

ind = thresh<0;
thr = thresh(ind);
thr = thr(find(diff(sign(R(ind,2) - target_ISI))==-2));
thresh_idle = thr(end);





