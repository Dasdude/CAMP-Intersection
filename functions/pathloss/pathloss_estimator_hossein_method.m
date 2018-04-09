function [alpha,epsilon,tx_height] = pathloss_estimator_hossein_method(data_mean_estimate,tx_height,carrier_freq,packet_loss_stat,trunc_val,tx_power,parameter_window_size,fixed_fading_bin_size,dist_lambda)
%PATHLOSS_ESTIMATOR Summary of this function goes here
%   Detailed explanation goes here
    lambda = 3*10^8/carrier_freq;
    per = packet_loss_stat(:,1)./packet_loss_stat(:,2);
    pathloss_mean_estimate = data_mean_estimate;
    [params_alpha_eps,alphas] = two_ray_dif_pathloss(pathloss_mean_estimate,tx_height,tx_height,lambda,carrier_freq,parameter_window_size,fixed_fading_bin_size,dist_lambda);
%     figure;plot(1:800,params_alpha_eps(:,1),1:800,params_alpha_eps(:,2));legend('alpha','epsilon');xlim([0,800]);ylim([.9,4])
%     figure;scatter(params_alpha_eps(:,1),params_alpha_eps(:,2));legend('alpha','epsilon');xlim([0,4]);ylim([.9,4]);
%     clusterdata(params_alpha_eps);
    alpha = params_alpha_eps(:,1)';
    epsilon = params_alpha_eps(:,2)';
    tx_height = params_alpha_eps(:,3)';
%     estimated_pathloss_two_ray_composite = pathloss_gen_2ray_multi(tx_height,tx_height,epsilon,alpha,lambda,800);
%     figure;plot(1:800,estimated_pathloss_two_ray_composite,1:800,pathloss_mean_estimate(:,1))
%     figure;c=histogram(alphas);
end

