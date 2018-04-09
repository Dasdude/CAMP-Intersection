function [params,loss_val] = mle_nakagami_truncated_variance_invariant_smooth(params_mu_omega_init,data,per_rate,trunc_val,mu_lower_bound)
%MLE_NAKAGAMI_TRUNCATED Summary of this function goes here
%   Detailed explanation goes here
total_edge = 100;
fun = @(x)loglikelihood_nakagami_variance_invariant_adptv_pdf_uniform(x,data,per_rate,32);
% options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton','MaxFunctionEvaluations',10000)
options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
% [params,loss_val]=fminunc(fun,params_mu_omega_init,options);
% while loss_val>.01
if isempty(data)
    params = params_mu_omega_init;
    loss_val = 0;
else
    [params,loss_val]=fmincon(fun,params_mu_omega_init,[],[],[],[],[max(mu_lower_bound,.5),eps],[10,10],[],options);
end
% end
if loss_val==0
    loss_val
end



% pdf_nak_estimated = makedist('Nakagami','mu',params(1),'omega',params(2));
% model_std_trunc = std_mean_pdf_truncated(pdf_nak_estimated,per_rate);
% % scale = std(data)./model_std_trunc;
% 
% model_pdf_trunc_val = icdf(pdf_nak_estimated,per_rate);
% 
% [data_pmf,lower_edge,upper_edge] = calculate_pmf_adptv_2(data);
% edge_center  = (lower_edge+upper_edge)/2;
% edge_center(1) = upper_edge(1);edge_center(end) = lower_edge(end);
% width = upper_edge-lower_edge;
% data_pdf = data_pmf./width;
% model_pdf_samples = pdf(pdf_nak_estimated,edge_center);
% model_cdf_lower = cdf(pdf_nak_estimated,lower_edge);
% model_cdf_upper = cdf(pdf_nak_estimated,upper_edge);
% model_pmf = model_cdf_upper-model_cdf_lower;
% model_pdf_samples_trunc = model_pdf_samples;model_pdf_samples_trunc(edge_center<model_pdf_trunc_val)=eps;
% model_pmf_samples_trunc = model_pmf;model_pmf_samples_trunc(edge_center<model_pdf_trunc_val)=eps;
% figure('Visible','off');plot(edge_center,data_pdf,'g');hold on;plot(edge_center,model_pdf_samples,'r',edge_center,model_pdf_samples_trunc,'b');
% figure('Visible','off');plot(edge_center,data_pmf,'g');hold on;plot(edge_center,model_pmf,'r',edge_center,model_pmf_samples_trunc,'b');




% trunc_value = min(data(:));
% pdf_nak_estimated = makedist('Nakagami','mu',params(1),'omega',params(2));
% data_edge_max = max(data(:));data_edge_max = max(data_edge_max,1);pdf_edge_max = icdf(pdf_nak_estimated,.999);edge_max = max(pdf_edge_max,data_edge_max);
% [bandwidth,data_density,xmesh,data_cdf]=kde(data,total_edge,0,edge_max);
% data_cdf = data_cdf';
% data_cdf=  data_cdf./max(data_cdf);
% t_val_idx = find(xmesh<=trunc_value,1,'last');
% data_cdf_trunc = data_cdf(t_val_idx:end);
% xmesh_trunc = xmesh(t_val_idx:end);
% 
% [~,~,~,data_std_trunc] = cdf2pmf(data_cdf_trunc,xmesh_trunc);



% t_val_model = icdf(pdf_nak_estimated,per_rate);
% last_edge_model = icdf(pdf_nak_estimated,.999);
% bin_size = (last_edge_model-t_val_model)./total_edge;
% edges_model = t_val_model:bin_size:last_edge_model;
% model_cdf_trunc = cdf(pdf_nak_estimated,edges_model);
% 
% [~,~,~,model_std_trunc] = cdf2pmf(model_cdf_trunc,edges_model);
% 
% scale = model_std_trunc./data_std_trunc;
% scale=1;
params = [params,1];
% Try to use fsearch or other functions fminunc is for non-linear
end

