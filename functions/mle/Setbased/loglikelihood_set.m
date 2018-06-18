function [loss] = loglikelihood_set(params_mu_omega,data,per_rate,make_dist_handle)
%LOGLIKELIHOOD Summary of this function goes here
pdf_nak_estimated = make_dist_handle(params_mu_omega);
% pdf_nak_estimated = makedist('lognakagami','mu',params_mu_omega(1),'sigma',params_mu_omega(2));
ll_list = zeros(1,length(data));
samples_per_cell = funoncellarray1input(data,@length);
samples_per_cell(isnan(samples_per_cell))=0;
% per_center = per_rate(current_index);
% data_center = data{current_index};
% std_min_samples = 200;
for i =1:length(data)
    if isempty(data{i})
        per_rate(i)=0;
        continue;
    end
    data_scaled =data{i};
%     current_per = per_rate(i);
    model_pdf_trunc_val = icdf(pdf_nak_estimated,per_rate(i));
    model_pdf_samples = pdf(pdf_nak_estimated,data_scaled);
    model_pdf_samples = model_pdf_samples*(1/(1-per_rate(i)));
    model_pdf_samples(model_pdf_samples<eps)=eps;
    model_pdf_samples(data_scaled<model_pdf_trunc_val)=eps;
    red_data = data_scaled(data_scaled<model_pdf_trunc_val);
    if per_rate(i)~=0
%         distance_loss = sum(((log(red_data)-log(model_pdf_trunc_val))*length(red_data)./length(data)).^2);
        distance_loss = sum(abs(log(red_data)-log(model_pdf_trunc_val)).^5);
    else
        distance_loss=0;
    end
    ll_list(i) = -mean(log2(model_pdf_samples));
    
    ll_list(i) = ll_list(i)+distance_loss;    
    if ll_list(i)==inf||ll_list(i)==-inf||isnan(ll_list(i))
        ll_list(i)
    end
end

loss = mean(ll_list.*(samples_per_cell./(1-per_rate'))./sum((samples_per_cell./(1-per_rate'))));

% loss = mean(ll_list.*(samples_per_cell)./sum(samples_per_cell));
if isnan(loss)||loss==inf||loss==-inf
    loss
end
end

