function [n_bins] = optimizeedge(data,bin_init)
%OPTIMIZEEDGE Summary of this function goes here
%   Detailed explanation goes here
ent_handle = @(x)entropy_quant(data,x);
options = optimoptions(@fmincon,'Display','iter','Algorithm','sqp','MaxFunctionEvaluations',100);
[params,loss_val]=fmincon(ent_handle,bin_init,[],[],[],[],2,[10],[],options);
n_bins = params(1);
end

