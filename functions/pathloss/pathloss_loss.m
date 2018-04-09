function [loss] = pathloss_loss(pathloss_emp,tx_height,carrier_freq,alpha_eps,per)
%PATHLOSS_LOSS Summary of this function goes here
%   Detailed explanation goes here
lambda = 3*10^8/carrier_freq;
d_max = length(pathloss_emp);
pathloss = pathloss_gen_2ray(tx_height,tx_height,alpha_eps(2),alpha_eps(1),lambda,d_max);
dif = pathloss_emp - pathloss;
dif(per>.5) = 0;
dif(200:800)= 0;
dif(1:70)= 0;
dif(isnan(dif))=0;
loss = mean(abs(dif).^2,'omitnan');
end

