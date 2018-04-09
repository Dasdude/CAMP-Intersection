function [kld] = loglikelihood_nakagami_variance_invariant_adptv_pdf_kde(params_mu_omega,data,per_rate,total_edge)
%LOGLIKELIHOOD Summary of this function goes here
%   not working for per>0 yet
trunc_value = min(data(:));
pdf_nak_estimated = makedist('Nakagami','mu',params_mu_omega(1),'omega',params_mu_omega(2));
data_edge_max = max(data(:));data_edge_max = max(data_edge_max,1);pdf_edge_max = icdf(pdf_nak_estimated,.999);edge_max = max(pdf_edge_max,data_edge_max);
[bandwidth,data_density,xmesh,data_cdf]=kde(data,total_edge,0,edge_max);
data_cdf= data_cdf';
data_cdf=  data_cdf./max(data_cdf);
t_val_idx = find(xmesh<=trunc_value,1,'last');
data_cdf_trunc = data_cdf(t_val_idx:end);
xmesh_trunc = xmesh(t_val_idx:end);

[data_pmf_trunc,xmesh_trunc_center,data_mean_trunc,data_std_trunc] = cdf2pmf(data_cdf_trunc,xmesh_trunc);



t_val_model = icdf(pdf_nak_estimated,per_rate);
last_edge_model = icdf(pdf_nak_estimated,.999);
bin_size = (last_edge_model-t_val_model)./total_edge;
edges_model = t_val_model:bin_size:last_edge_model;
model_cdf_trunc = cdf(pdf_nak_estimated,edges_model);

[model_pmf_trunc,modelmesh_trunc_center,model_mean_trunc,model_std_trunc] = cdf2pmf(model_cdf_trunc,edges_model);

scale = model_std_trunc./data_std_trunc;
data_scaled = data.*scale;

data_edge_max = max(data_scaled(:));data_edge_max = max(data_edge_max,1);pdf_edge_max = icdf(pdf_nak_estimated,.999);edge_max = max(pdf_edge_max,data_edge_max);

[bandwidth,data_density,xmesh,data_scaled_cdf]=kde(data_scaled,total_edge,0,edge_max);
data_scaled_cdf = data_scaled_cdf';
t_val_idx = find(xmesh<=trunc_value,1,'last');
data_scaled_cdf_trunc=  data_scaled_cdf./max(data_scaled_cdf);
data_scaled_cdf_trunc(1:t_val_idx)=eps;
[data_pmf_trunc,~,~,~] = cdf2pmf(data_scaled_cdf_trunc,xmesh);


cdf_model = cdf(pdf_nak_estimated,xmesh);
t_val_model = find(xmesh<=trunc_value,1,'last');
cdf_model(1:t_val_model)=eps;
[pmf_model,~,~,~] = cdf2pmf(cdf_model,xmesh);


kld = (-sum(data_pmf_trunc.*log2(pmf_model+eps)) + sum(data_pmf_trunc.*log2(data_pmf_trunc+eps)));
if isnan(kld)|| ~isreal(kld)
    kld
end
if kld<0
    error('ERROR. KLD Value is negative')
end
end

