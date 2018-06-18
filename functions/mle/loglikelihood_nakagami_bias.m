function [kld] = loglikelihood_nakagami_bias(params_mu_omega_bias,data,per_rate,trunc_val)
%LOGLIKELIHOOD Summary of this function goes here
%   Detailed explanation goes here
edge_num = 500;
edge_size = .01;
pdf_nak_estimated = makedist('Nakagami','mu',params_mu_omega_bias(1),'omega',params_mu_omega_bias(2));
data_biased = data-params_mu_omega_bias(3);
[pdf_gt,edges] = hist(data_biased,-5:edge_size:5);
lower = 2*edges(1)-edges(2);
upper = 2*edges(end)-edges(end-1);
edge_upper = [edges(2:end),upper];
upper_interval = edge_upper-edges;

pdf_gt = (1-per_rate)*(pdf_gt./sum(pdf_gt));

est_pdf_trunc_val = icdf(pdf_nak_estimated,per_rate);
data_est_pdf_edges = pdf(pdf_nak_estimated,edges);
data_set_nak_pmf = data_est_pdf_edges.*edge_size;
% data_set_nak_pmf = data_set_nak_pmf;
data_set_nak_pmf(edges<est_pdf_trunc_val) =eps;
data_set_nak_pmf = data_set_nak_pmf./sum(data_set_nak_pmf);
pdf_gt = pdf_gt./sum(pdf_gt);
% data_set_pmf
% data_p(data<est_pdf_trunc)=eps;
kld = -sum(pdf_gt.*log2(data_set_nak_pmf+eps)) + sum(pdf_gt.*log2(pdf_gt+eps));
% kld=kld+abs((trunc_val-est_pdf_trunc_val).^2);
% kld=log(abs((trunc_val-est_pdf_trunc_val)).^2+eps)-log(eps);
if kld<0
    error('ERROR. KLD Value is negative')
end
end

