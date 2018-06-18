function [kld] = loglikelihood_nakagami_median_invariant(params_mu_omega,data,per_rate,trunc_val)
%LOGLIKELIHOOD Summary of this function goes here
%   Detailed explanation goes here
alpha =0;
edge_size = .1;
pivot_cdf_val = ((1-per_rate)./2)+per_rate;
pdf_nak_estimated = makedist('Nakagami','mu',params_mu_omega(1),'omega',params_mu_omega(2));
pivot = icdf(pdf_nak_estimated,pivot_cdf_val);
shift_val = pivot-median(data);
data_biased = data+shift_val;
[pdf_gt,edges] = hist(data_biased,-5:edge_size:10);
upper = 2*edges(end)-edges(end-1);
edge_upper = [edges(2:end),upper];
data_est_cdf_lower = cdf(pdf_nak_estimated,edges);
data_est_cdf_upper = cdf(pdf_nak_estimated,edge_upper);
data_set_nak_pmf = data_est_cdf_upper-data_est_cdf_lower;
est_pdf_trunc_val = icdf(pdf_nak_estimated,per_rate);

data_set_nak_pmf(edges<est_pdf_trunc_val) =eps;
data_set_nak_pmf = data_set_nak_pmf./sum(data_set_nak_pmf);
pdf_gt = pdf_gt./sum(pdf_gt);

kld = (-sum(pdf_gt.*log2(data_set_nak_pmf+eps)) + sum(pdf_gt.*log2(pdf_gt+eps)))+alpha*(shift_val.^2);
if kld<0
    error('ERROR. KLD Value is negative')
end
end

