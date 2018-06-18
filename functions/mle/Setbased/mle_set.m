function [params,loss_val] = mle_set(params_mu_omega_init,data,per_rate,current_index,dist_obj)
%MLE_NAKAGAMI_TRUNCATED Summary of this function goes here
%   Detailed explanation goes here
fun = @(x)loglikelihood_set(x,data,per_rate,dist_obj.dist_handle);
options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
if length(data{current_index})<10
    params = params_mu_omega_init;
    loss_val = 0;
else
    [params,loss_val]=fmincon(fun,params_mu_omega_init,[],[],[],[],dist_obj.dist_params_bounds_min,dist_obj.dist_params_bounds_max,[],options);
end
end
