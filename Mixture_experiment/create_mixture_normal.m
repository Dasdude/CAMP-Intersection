function [mixture_samples,per,mixture_samples_all] = create_mixture_normal(total_samples,mu,sigma,p,threshold)
%CREATE_MIXTURE Summary of this function goes here
%   Detailed explanation goes here
% mu_y1 = [2,3,1,5,7]
% sigma_y1 = [1,1,2,1,1.5];
p_normalized = p./sum(abs(p));
% mu
% sigma
samples = int64(randn(length(p),total_samples).*repmat(sigma',1,total_samples)+repmat(mu',1,total_samples));
mixture_samples = [];
for i = 1:length(p)
    mixture_samples = [mixture_samples,randsample(samples(i,:),int64(p_normalized(i)*total_samples))];
    
    
end
mixture_samples_all =double(mixture_samples);
mixture_samples_censored = mixture_samples_all(mixture_samples_all<threshold);
mixture_samples = mixture_samples_all(mixture_samples_all>=threshold);
per = length(mixture_samples_censored)./length(mixture_samples_all);
% loss = mixture_loss(mixture_samples',p,mu,sigma);
% sprintf('loss:%d',loss)
% sprintf('p:')
% disp(p_normalized)
% sprintf('mu:')
% disp(mu)
% sprintf('sigma:')
% disp(abs(sigma))
end

