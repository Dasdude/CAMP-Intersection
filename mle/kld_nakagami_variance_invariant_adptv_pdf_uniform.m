function [kld] = kld_nakagami_variance_invariant_adptv_pdf_uniform(params_mu_omega,data,per_rate,total_edge)
%LOGLIKELIHOOD Summary of this function goes here
pdf_nak_estimated = makedist('Nakagami','mu',params_mu_omega(1),'omega',params_mu_omega(2));
model_std_trunc = std_mean_pdf_truncated(pdf_nak_estimated,per_rate);
data_std = std(data);
if data_std==0
    data_std=model_std_trunc;
end
scale = model_std_trunc./data_std;
% data_scaled = data.*scale;
data_scaled =data;
model_pdf_trunc_val = icdf(pdf_nak_estimated,per_rate);
[data_pmf,lower_edge,upper_edge]= calculate_pmf_adptv(data_scaled,total_edge);
model_cdf_lower= cdf(pdf_nak_estimated,lower_edge);
model_cdf_upper = cdf(pdf_nak_estimated,upper_edge);
model_pmf = model_cdf_upper-model_cdf_lower;
model_pmf((upper_edge+lower_edge./2)<model_pdf_trunc_val)=0;



kld = (-sum(data_pmf.*log2(model_pmf+eps)) + sum(data_pmf.*log2(data_pmf+eps)));

if isnan(kld)|| ~isreal(kld)
    kld
end
if kld<0
    error('ERROR. KLD Value is negative')
end
end

