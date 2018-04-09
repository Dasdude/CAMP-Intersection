function [alpha_res,alphas] = pathloss_dif_loss_find_alpha(d1,d2,pathloss,epsilon,Tx_height,Rx_height,lambda,window)
%PATHLOSS_DIF_LOSS Summary of this function goes here
%   Detailed explanation goes here
pathloss_2ray_epsilonfun_term = pathloss_gen_2ray(Tx_height,Rx_height,epsilon,1,lambda,d2+1);
d2 = min(length(pathloss),d2);
alphas = [];
for c1 = d1:d2
    min_range = max([1,c1-window,d1]);max_range=min([length(pathloss),c1+window,d2]);
    for c2 = min_range:max_range
        
        d_pathloss_emp = pathloss(c2)-pathloss(c1);
        if isnan(d_pathloss_emp) || c2==c1
            continue;
        end
        d_pathloss_2ray_epsilonfun = pathloss_2ray_epsilonfun_term(c2)-pathloss_2ray_epsilonfun_term(c1);
        alpha_i = d_pathloss_emp./d_pathloss_2ray_epsilonfun;
        alphas=[alphas,alpha_i];
%         loss = loss+abs(d_pathloss_2ray-d_pathloss_emp);        
    end
end
alpha_res = median(alphas);
end

