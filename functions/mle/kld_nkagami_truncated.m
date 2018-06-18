function [outputArg1,outputArg2] = kld_nkagami_truncated(params_mu_omega,data,per_rate,trunc_val)
%KLD_NKAGAMI_TRUNCATED Summary of this function goes here
%   Detailed explanation goes here
pd_nak = makedist('Nakagami','mu',params_mu_omega(1),'omega',params_mu_omega(2));
est_pdf_trunc = icdf(pd_nak,per_rate);
data_p = pdf(pd_nak,data)./(1-per_rate);
% data_p(data<est_pdf_trunc)=eps;
data_sel = data_p(data>est_pdf_trunc);
ll = -sum(log2(data_sel));

end

