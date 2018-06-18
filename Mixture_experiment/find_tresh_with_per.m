function [tr] = find_tresh_with_per(dist_name,p,mu,sigma,per)
%FIND_TRESH_WITH_PER Summary of this function goes here
%   Detailed explanation goes here
sigma = abs(sigma);
tr_expand = icdf(dist_name,per,mu,abs(sigma));
icdf_vec = (floor(min(tr_expand)):.01:ceil(max(tr_expand)))';
icdf_vec_expand = double(repmat(icdf_vec,1,length(mu)));
mu_expand = repmat(mu,length(icdf_vec),1);
sigma_expand = repmat(sigma,length(icdf_vec),1);
p_expand = repmat(p,length(icdf_vec),1);
cdf_vals_expand = cdf(dist_name,icdf_vec_expand,mu_expand,sigma_expand);
cdf_vals= p_expand.*cdf_vals_expand;
cdf_vals_mix = sum(cdf_vals,2);
tr_idx = find(cdf_vals_mix>per,1);
tr  =icdf_vec(tr_idx);
if isempty(tr)
%     'tr calc is empty'
    tr=-inf;
end
% pdf_values = cdf(dist_name,icdf_vec',abs(sigma))
end

