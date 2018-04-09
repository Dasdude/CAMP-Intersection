function [loss] = pathloss_dif_loss_epsilon_find_std_based(d1,d2,pathloss,alpha,epsilon,Tx_height,Rx_height,lambda,window)
%PATHLOSS_DIF_LOSS Summary of this function goes here
%   Detailed explanation goes here
pathloss_2ray_epsilonfun_term = pathloss_gen_2ray(Tx_height,Rx_height,epsilon,alpha,lambda,d2+1);
window = 10;
d2 = min(length(pathloss),d2);
alphas = [];
for c1 = d1:d2
    min_range = max([1,c1-window,d1]);max_range=min([length(pathloss),c1+window,d2]);
    for c2 = min_range:max_range
        
        d_pathloss_emp = pathloss(c2)-pathloss(c1);
        d_pathloss_epsilonfun_term = pathloss_2ray_epsilonfun_term(c2)-pathloss_2ray_epsilonfun_term(c1);
        
        if isnan(d_pathloss_emp) || c1==c2
            continue;
        end
        alpha = d_pathloss_emp./d_pathloss_epsilonfun_term;
        alphas = [alphas,alpha];
    end
    
end
loss = std(alphas);
end

