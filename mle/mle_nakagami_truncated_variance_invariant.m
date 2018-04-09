function [params,loss_val] = mle_nakagami_truncated_variance_invariant(params_mu_omega_init,data,per_rate,trunc_val,mu_lower_bound)
%MLE_NAKAGAMI_TRUNCATED Summary of this function goes here
%   Detailed explanation goes here
fun = @(x)loglikelihood_nakagami_variance_invariant(x,data,per_rate,trunc_val);
% options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton','MaxFunctionEvaluations',10000)
options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
% [params,loss_val]=fminunc(fun,params_mu_omega_init,options);
% while loss_val>.01

[params,loss_val]=fmincon(fun,params_mu_omega_init,[],[],[],[],[max(mu_lower_bound,.5),eps],[10,10],[],options);
params_mu_omega_init = [randi(10),randi(10)];
% end
if loss_val==0
    loss_val
end
pdf_nak_estimated = makedist('Nakagami','mu',params(1),'omega',params(2));
pathloss_error = std(data)./std(pdf_nak_estimated);
params = [params,pathloss_error];
% Try to use fsearch or other functions fminunc is for non-linear
end

