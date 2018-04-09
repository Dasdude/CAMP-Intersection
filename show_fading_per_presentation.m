clc
close all
clear

per = .75;
mu= 8
omega = 9
a = nakagami_generator([mu,omega,1],100000);
a = a{1};

pd = makedist('Nakagami','mu',mu,'omega',omega)
tr_val = icdf(pd,per);
a_tr = a(a>tr_val);
params_per = mle_nakagami_truncated([1,1],a_tr,per,a_tr,0);
params = mle_nakagami_truncated([1,1],a_tr,0,a_tr,0);
est_a = nakagami_generator([params(1),params(2),1],100000);

est_a_per = nakagami_generator([params_per(1),params_per(2),1],100000);
a_hist = histogram(a,'FaceColor','b');
binEdges = a_hist.BinEdges
ylim([0,4000])
hold on
ylim([0,4000])
est_a_hist = histogram(est_a{1},binEdges,'FaceColor','r');
ylim([0,4000])
est_a_per_hist = histogram(est_a_per{1},binEdges,'FaceColor','y');
ylim([0,4000])
a_tr_hist  = histogram(a_tr,binEdges,'FaceColor','g');
ylim([0,4000])
box off
axis tight
legend('True Distribution','Estimated Dist without PER','Estimated Dist with PER','Truncated Distribution')
title(['Nakagami Estimating Distribution with PER:',num2str(per)])