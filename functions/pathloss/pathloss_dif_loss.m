function [loss] = pathloss_dif_loss(d1,d2,pathloss,alpha,epsilon,Tx_height,Rx_height,lambda,window,dist_lambda)
%PATHLOSS_DIF_LOSS Summary of this function goes here
%   Detailed explanation goes here
pathloss_2ray = pathloss_gen_2ray(Tx_height,Rx_height,epsilon,alpha,lambda,d2+1);
pathloss_2ray_epsilonfun_term = pathloss_gen_2ray(Tx_height,Rx_height,epsilon,1,lambda,d2+1)./10;
loss = 0;
d2 = min(length(pathloss),d2);
for c1 = d1:d2
    min_range = max([1,c1-window,d1]);max_range=min([length(pathloss),c1+window,d2]);
    for c2 = min_range:max_range
        
        d_pathloss_emp = pathloss(c2)-pathloss(c1);
        if isnan(d_pathloss_emp)
            continue;
        end
        d_pathloss_2ray = pathloss_2ray(c2)-pathloss_2ray(c1);
        loss_dif = abs(d_pathloss_2ray-d_pathloss_emp);
        if isnan(loss_dif)
            continue;
        end
        loss = loss+loss_dif;        
    end
end
loss_dist = abs(pathloss_2ray(c2)-pathloss(c2)).^2;
if isnan(loss_dist)
    loss_dist=0;
end
loss = loss+ dist_lambda.*sum(loss_dist);

end

