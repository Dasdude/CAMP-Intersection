function [params,loss_val] = mle_set_nakagami(params_mu_omega_init,data,per_rate,mu_lower_bound,current_index,min_samples_per_cell)
%MLE_NAKAGAMI_TRUNCATED Summary of this function goes here
%   Detailed explanation goes here
fun = @(x)loglikelihood_nakagami_set(x,data,per_rate,current_index,min_samples_per_cell);
% options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton','MaxFunctionEvaluations',10000)
options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
% [params,loss_val]=fminunc(fun,params_mu_omega_init,options);
% while loss_val>.01
if length(data{current_index})<10
    params = params_mu_omega_init;
    loss_val = 0;
else
    [params,loss_val]=fmincon(fun,params_mu_omega_init,[],[],[],[],[max(mu_lower_bound,.5),eps],[10,10],[],options);
end
% end
end
