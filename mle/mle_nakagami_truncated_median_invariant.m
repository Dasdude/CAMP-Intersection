function [params,loss_val] = mle_nakagami_truncated_median_invariant(params_mu_omega_init,data,per_rate,trunc_val,mu_lower_bound)
%MLE_NAKAGAMI_TRUNCATED Summary of this function goes here
%   Detailed explanation goes here
fun = @(x)loglikelihood_nakagami_median_invariant(x,data,per_rate,trunc_val);
% options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton','MaxFunctionEvaluations',10000)
options = optimoptions(@fmincon,'Display','final','Algorithm','interior-point','MaxFunctionEvaluations',10000);
% [params,loss_val]=fminunc(fun,params_mu_omega_init,options);
% while loss_val>.01

[params,loss_val]=fmincon(fun,params_mu_omega_init,[],[],[],[],[max(mu_lower_bound,.5),eps],[],[],options);
params_mu_omega_init = [randi(10),randi(10)];
% end
pdf_nak_estimated = makedist('Nakagami','mu',params(1),'omega',params(2));
pivot_cdf_val = ((1-per_rate)./2)+per_rate;
pivot = icdf(pdf_nak_estimated,pivot_cdf_val);
pathloss_error = pivot-median(data);
params = [params,pathloss_error];
% Try to use fsearch or other functions fminunc is for non-linear
end

