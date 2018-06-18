function [kld] = loglikelihood_nakagami_variance_invariant(params_mu_omega,data,per_rate,trunc_val)
%LOGLIKELIHOOD Summary of this function goes here
%   not working for per>0 yet
alpha =0;
edge_size = .01;
pivot_cdf_val = ((1-per_rate)./2)+per_rate;
pdf_nak_estimated = makedist('Nakagami','mu',params_mu_omega(1),'omega',params_mu_omega(2));
shift_val = std(pdf_nak_estimated)./std(data);
data_biased = data*shift_val;
edge_size = edge_size*shift_val;
data_edge_max = max(data_biased(:));
data_edge_max = max(data_edge_max,1);
pdf_edge_max = icdf(pdf_nak_estimated,.999);
[pdf_gt,edges] = hist(data_biased,0:edge_size:max(pdf_edge_max,data_edge_max));
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

