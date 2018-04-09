function [params,bin_start_edges,approximated_per,loss_values] = mean_estimator_gaussian_mle_adptv_bin_window(fading_linear_cell,init_param,d_min,per_stat,truncation_value,min_samples,max_window_size,file_name,store_dist)
%FADING_ESTIMATOR_NAKAGAMI_MLE_ADPTV_BIN Summary of this function goes here
%   Detailed explanation goes here
    bin_size=1;
    max_bin_size = max_window_size;
    params = zeros(length(fading_linear_cell),3)*nan; % R x 3 : Range x [mu,omega,bias]
    histogram_folder_name = 'gaussian estimate dist histograms';
    mkdir(['Plots/',file_name,'/',histogram_folder_name]);
    %%
    bin_start_edges = (d_min:bin_size:length(fading_linear_cell))*0;
    bin_end_edges = (d_min:bin_size:length(fading_linear_cell))*0;
    bin_mid_edges = (d_min:bin_size:length(fading_linear_cell))*0;
    start_i = 1;
    edge_index =1;
    d_max = length(fading_linear_cell);
    fading_displacement = ones(1,d_max);
    for i= 1:length(bin_start_edges)
        [~,s,e] = collect_neighbour_data(fading_linear_cell,i,min_samples,max_bin_size);
        bin_start_edges(i) = s;
        bin_end_edges(i)=e;
        bin_mid_edges(i)=i;
    end
    bin_start_edges = bin_start_edges(bin_start_edges>0);
    bin_end_edges = bin_end_edges(bin_end_edges>0);
    %%
    approximated_per = zeros(1,d_max);
    loss_values = zeros(1,d_max)*nan;
    per_prev = 0; % previous bin per_value
    
    
    for i = 1:length(bin_start_edges)
        j=i-1;
        
        

        [fading_data_linear,s,e,samples_ratio] = collect_neighbour_data(fading_linear_cell,i,min_samples,max_bin_size);
        range_start = s;
        range_end = e;
%         fading_data_linear = concat_cell(fading_linear_cell,range_start,range_end);
        temp_index_start = max(1,s-1);
        initial_param_value = mean(params(temp_index_start:j,:),1,'omitnan');
        if isempty(fading_data_linear)
            params(i,:) =initial_param_value;
            continue
        end
        if any(isnan(initial_param_value))
            'initial param value nan'
            initial_param_value = [mean(fading_data_linear),std(fading_data_linear)];
        end
        per_value = sum(per_stat(range_start:range_end,1).*samples_ratio(range_start:range_end)')./ sum(per_stat(range_start:range_end,2).*samples_ratio(range_start:range_end)');
        approximated_per(range_start:range_end)=per_value;
        [params_res,loss] = mle_gaussian_truncated_variance_invariant_smooth(initial_param_value(1:2),fading_data_linear,per_value,truncation_value,.5);
        fprintf('kld loss %d:%d for bin %d : %d \n',range_start,range_end,i,loss)
        if store_dist&& all(~isnan(params_res))
            histogram_samples_vs_dist(fading_data_linear,'normal',params_res,10000,per_value,['Bin ',num2str(i),' Sample range ',num2str(range_start),':',num2str(range_end),' '])
            saveas(gcf,['Plots/',file_name,'/',histogram_folder_name,'/',num2str(i),'.png']);
            close gcf
        end
        loss_values(i) = loss;
        if size(params_res,2) ==2
            params_res(3) =0;
        end
        params(i,:) =params_res;
    end
    
end

