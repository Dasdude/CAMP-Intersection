function [loss] = loglikelihood_nakagami_variance_invariant_adptv_pdf_uniform(params_mu_omega,data,per_rate,total_edge)
%LOGLIKELIHOOD Summary of this function goes here
pdf_nak_estimated = makedist('Nakagami','mu',params_mu_omega(1),'omega',params_mu_omega(2));

data_scaled =data;
model_pdf_trunc_val = icdf(pdf_nak_estimated,per_rate);
model_pdf_samples = pdf(pdf_nak_estimated,data_scaled);
model_pdf_samples(model_pdf_samples<eps)=eps;
model_pdf_samples(data_scaled<model_pdf_trunc_val)=1e-200;
min_data = prctile(data,5);
red_data = data(data<model_pdf_trunc_val);
if per_rate~=0
    distance_loss = sum(((log(red_data)-log(model_pdf_trunc_val))*length(red_data)./length(data)).^2);
else
    distance_loss=0;
end
% min_dist = abs(min_data - model_pdf_trunc_val).^2;
ll = -mean(log2(model_pdf_samples));
loss = ll+distance_loss;

% if isnan(kld)|| ~isreal(kld)
%     kld
% end
% if kld<0
%     error('ERROR. KLD Value is negative')
% end
end

