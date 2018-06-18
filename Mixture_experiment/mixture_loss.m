function [ll] = mixture_loss(samples,p,mu,sigma,dist_name,per)
%MIXTURE_LOSS mu 1xn sigma= 1xn p = 1xn samples = mx1
%   Detailed explanation goes here
p = abs(p)./sum(abs(p));
sigma = abs(sigma);
mu_expand = repmat(mu,length(samples),1);
sigma_expand = repmat(sigma,length(samples),1);
samples_expand = double(repmat(samples,1,length(sigma)));
tr = find_tresh_with_per(dist_name,p,mu,sigma,per);
% tr_expand = icdf(dist_name,per,mu,abs(sigma));
% icdf_vec = floor(min(tr_expand)):ceil(max(tr_expand));
% pdf_values = cdf(dist_name,icdf_vec',abs(sigma))
pdf_values = cdf(dist_name,samples_expand+.5,mu_expand,abs(sigma_expand))-cdf('normal',samples_expand-.5,mu_expand,abs(sigma_expand)); % mxdist
pdf_values = pdf_values./(1-per);
pdf_values(samples_expand<tr)= .01*exp(-abs(samples_expand(samples_expand<tr)-tr).^2);
pdf_values(pdf_values<eps)=eps;
% pdf_values
p_normalized = abs(p)./sum(abs(p));
p_expand = repmat(p_normalized,length(samples),1);
ll = mean(-log2(sum(pdf_values.*p_expand,2)+eps))+.1*sum(p_normalized.*log2(p_normalized+eps));
regularizer = abs(tr-double(min(samples))).^2;
if isnan(ll)|isinf(ll)
    'll is undefined'
end
    
end

