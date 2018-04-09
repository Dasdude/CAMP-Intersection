function [params] = fading_estimator_nakagami_mle_adptv_bin(fading_linear_cell,init_param,bin_size,d_min,per_stat,truncation_value,min_samples,total_packets)
%FADING_ESTIMATOR_NAKAGAMI_MLE_ADPTV_BIN Summary of this function goes here
%   Detailed explanation goes here
    params = zeros(length(fading_linear_cell),2)*nan; % R x 2 : Range x [mu,omega]
    %%
    bin_start_edges = d_min:bin_size:length(fading_linear_cell)*0;
    bin_end_edges = d_min:bin_size:length(fading_linear_cell)*0;
    start_i = 1;
    edge_index =1;
    d_max = length(fading_linear_cell);
    while start_i<=d_max
        
        end_i = min(start_i+bin_size-1,d_max);
        while (sum(total_packets(start_i:end_i))<min_samples) && (end_i< d_max)
            end_i=end_i+1;
        end
        bin_start_edges(edge_index) = start_i;
        bin_end_edges(edge_index) = end_i;
        edge_index = edge_index+1;
        start_i = end_i+1;
    end
    bin_start_edges = bin_start_edges(bin_start_edges>0);
    bin_end_edges = bin_end_edges(bin_end_edges>0);
    %%
    per_prev = 0; % previous bin per_value
    for i = 1:length(bin_start_edges)
        j=i-1;
        initial_param_value = init_param+eps;
        while j>=1
            if ~any(isnan(params(j,:)))
                initial_param_value = params(j,:);
                break;
            end
            j=j-1;
        end
        range_start = bin_start_edges(i);
        range_end = bin_end_edges(i);
        fading_data_linear = fading_linear_cell{range_start:range_end};
        per_value = sum(per_stat(range_start:range_end,1))./ sum(per_stat(range_start:range_end,2));
        per_value = max(per_value,per_prev);
        per_prev = per_value;
        if isempty(fading_data_linear)
            params(range_start:range_end,:)=nan;
            continue;
        end
        params_res = mle_nakagami_truncated(initial_param_value,fading_data_linear,per_value,truncation_value,initial_param_value(1));
        params(range_start:range_end,:) = repmat(params_res,range_end-range_start+1,1);
    end
end

