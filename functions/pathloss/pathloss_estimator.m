function [alpha,eps,pathloss_expand_emp] = pathloss_estimator(data_cell,tx_height,carrier_freq,per,trunc_val,tx_power)
%PATHLOSS_ESTIMATOR Summary of this function goes here
%   Detailed explanation goes here
    data_cell_expand = concat_data_per_based(data_cell,per,trunc_val);
    pathloss_expand_emp = funoncellarray1input(data_cell_expand,@median);
    pathloss_expand_emp = tx_power-pathloss_expand_emp;
    
    loss_handle = @(x) pathloss_loss(pathloss_expand_emp,tx_height,carrier_freq,x(1:2),per);
    options = optimoptions(@fmincon,'Display','iter','Algorithm','interior-point','MaxFunctionEvaluations',10000);
    [params,loss_val]=fmincon(loss_handle,[1+.0001,1+.0001],[],[],[],[],[1,1],[10,10],[],options);
    params
    alpha = params(1);
    eps = params(2);
end

