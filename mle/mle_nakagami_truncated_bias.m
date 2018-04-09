function [params,loss_val] = mle_nakagami_truncated_bias(params_mu_omega_init,data,per_rate,trunc_val,mu_lower_bound)
%MLE_NAKAGAMI_TRUNCATED Summary of this function goes here
%   Detailed explanation goes here
fun = @(x)loglikelihood_nakagami_bias_v2(x,data,per_rate,trunc_val);
% options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton','MaxFunctionEvaluations',10000)
options = optimoptions(@fmincon,'Display','iter','Algorithm','interior-point','MaxFunctionEvaluations',10000);
% [params,loss_val]=fminunc(fun,params_mu_omega_init,options);
[params,loss_val]=fmincon(fun,params_mu_omega_init,[],[],[],[],[max(mu_lower_bound,.5),eps,-inf],[],[],options)
% Try to use fsearch or other functions fminunc is for non-linear
end

