function [params,loss_val] = mle_nakagami_truncated_bias_iterative(params_mu_omega_init,data,per_rate,trunc_val,mu_lower_bound)
%MLE_NAKAGAMI_TRUNCATED Summary of this function goes here
%   Detailed explanation goes here
options = optimoptions(@fmincon,'Display','iter','Algorithm','interior-point','MaxFunctionEvaluations',10000);
loss_val = inf;
mu = params_mu_omega_init(1);
omega = params_mu_omega_init(2);
mean = params_mu_omega_init(3);
while loss_val>.001
    fun_omega_mu = @(x)loglikelihood_nakagami_bias_v2([x,mean],data,per_rate,trunc_val);
    [params,loss_val]=fmincon(fun_omega_mu,[mu,omega],[],[],[],[],[max(mu_lower_bound,.5),eps],[],[],options);
    mu = params(1);omega = params(2);
    fun_mean = @(x)loglikelihood_nakagami_bias_v2([mu,omega,x],data,per_rate,trunc_val);
    [params,loss_val]=fmincon(fun_mean,[mean],[],[],[],[],[-inf],[],[],options);
    mean = params(1)
    fun_omega_mean=@(x)loglikelihood_nakagami_bias_v2([mu,x],data,per_rate,trunc_val);
    [params,loss_val]=fmincon(fun_omega_mean,[omega,mean],[],[],[],[],[eps,-inf],[],[],options);
    fun_mu_mean=@(x)loglikelihood_nakagami_bias_v2([x(1),omega,x(2)],data,per_rate,trunc_val);
    omega = params(1);mean=params(2);
    [params,loss_val]=fmincon(fun_mu_mean,[mu,mean],[],[],[],[],[max(mu_lower_bound,.5),-inf],[],[],options);
    mu = params(1);mean = params(2);
end
params = [mu,omega,mean];
% options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton','MaxFunctionEvaluations',10000)

% [params,loss_val]=fminunc(fun,params_mu_omega_init,options);

% Try to use fsearch or other functions fminunc is for non-linear
end

