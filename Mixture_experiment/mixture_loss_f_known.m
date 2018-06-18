function [ll] = mixture_loss_f_known(samples,mu,sigma)
%MIXTURE_LOSS mu 1xn sigma= 1xn p = 1xn samples = mx1
%   Detailed explanation goes here
% total_dist = length(p);
mu_expand = repmat(mu,length(samples),1);
sigma_expand = repmat(sigma,length(samples),1);
samples_expand = double(repmat(samples,1,length(sigma)));
pdf_values = cdf('normal',samples_expand+.5,mu_expand,abs(sigma_expand))-cdf('normal',samples_expand-.5,mu_expand,abs(sigma_expand)); % mxdist
mixture_loss_fn_fknown =@(x)mixture_loss(samples,x,mu,sigma); 
total_dist =    length(mu);
p_init = randn(1,total_dist);
% p_init = zeros(1,total_dist);
% p_init(randi(total_dist))=1;
% p_init = p1;
% mu_init = randn(1,total_dist)*2;
% sigma_init = abs(randn(1,total_dist));

init_param = [p_init];
options = optimoptions('fminunc','Display','iter');
p = fminunc(mixture_loss_fn_fknown,init_param,options);
p_normalized = abs(p)./sum(abs(p));
p_expand = repmat(p_normalized,length(samples),1);
% code_l = -log2(pdf_values+eps);
% [ll_min,idx] = min(-log2(pdf_values),[],2);
% p_min = hist(idx,1:total_dist);
% p_min = p_min./sum(p_min);
% p_min_expand = repmat(p_min,length(samples),1);
% ll_min_all = log2(pdf_values+eps)+log2(p_min_expand+eps); 
% ll_all = log2(pdf_values+eps)+log2(p_expand+eps); %mxdist
% ll_all = mean(sum(-ll_all.*p_expand,2));
% ll = ll_all;
% ll = log2(pdf_values+eps);
% ll2 = min(-ll_all')';
% % ll = mean(ll2);
% joint_pdf = pdf_values.*p_expand;
% machine_categorical_pdf_given_value = (joint_pdf+eps)./(sum(joint_pdf,2)+eps);
% machine_code_length =-sum(p_expand.*log2(machine_categorical_pdf_given_value+eps),2); 
% ll = mean(-log2(sum(pdf_values.*p_expand,2)+eps)+machine_code_length);
% if isnan(ll)|isinf(ll)|ll<0
%     ll
% end
ll = mean(-log2(sum(pdf_values.*p_expand,2)+eps))-.1*sum(p_normalized.*log2(p_normalized+eps));
% ll = mean(-log2(sum(pdf_values.*p_expand,2)+eps))+;
end

