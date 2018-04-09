function [ll] = loglikelihood_gaussian_variance_invariant_adptv_pdf_uniform(params_mu_omega,data,per_rate,params_init)
%LOGLIKELIHOOD Summary of this function goes here
pdf_nak_estimated = makedist('Normal','mu',params_mu_omega(1),'sigma',params_mu_omega(2));
prior_dist_sigma = 4;
ptheta_sigma = makedist('Normal','mu',params_init(2),'sigma',prior_dist_sigma);
ptheta = pdf(ptheta_sigma,params_mu_omega(2));
data_scaled =data;
min_data = prctile(data,5);
model_pdf_trunc_val = icdf(pdf_nak_estimated,per_rate);
model_pdf_samples = pdf(pdf_nak_estimated,data_scaled);

model_pdf_samples(model_pdf_samples==0)=1e-200;
model_pdf_samples(data_scaled<model_pdf_trunc_val)=1e-200;
red_data = data(data<model_pdf_trunc_val);
if per_rate~=0
    distance_loss = sum(((red_data-model_pdf_trunc_val)*length(red_data)./length(data)).^2);
else
    distance_loss = 0;
end
ll = -mean(log2(model_pdf_samples))-1*(log2(ptheta+eps)./length(model_pdf_samples))+distance_loss;
if all(model_pdf_samples==eps)
    ll = min(abs(-94-model_pdf_trunc_val))-mean(log2(model_pdf_samples))-1*(log2(ptheta+eps))+distance_loss;
%     'diverge'
end
end

