function [params,bin_start_edges,approximated_per,loss_values] = fading_estimator_nakagami_mle_adptv_bin_window(fading_linear_cell,init_param,d_min,per_stat,truncation_value,min_samples,max_window_size,file_name,show_dist,plot_min_max_val)
%FADING_ESTIMATOR_NAKAGAMI_MLE_ADPTV_BIN Summary of this function goes here
%   Detailed explanation goes here
    bin_size=1;
    max_bin_size = max_window_size;
    params = zeros(length(fading_linear_cell),3)*nan; % R x 3 : Range x [mu,omega,bias]
    log_histogram_folder_name = 'log nakagami estimate dist histograms';
    histogram_folder_name = 'nakagami estimate dist histograms';
    mkdir(['Plots/',file_name,'/',histogram_folder_name]);
    mkdir(['Plots/',file_name,'/',log_histogram_folder_name]);
    
    %%
    bin_start_edges = (d_min:bin_size:length(fading_linear_cell))*0;
    bin_end_edges = (d_min:bin_size:length(fading_linear_cell))*0;
    bin_mid_edges = (d_min:bin_size:length(fading_linear_cell))*0;
    start_i = 1;
    edge_index =1;
    d_max = length(fading_linear_cell);
    
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
    
    for i = 1:length(fading_linear_cell)
        j=i-1;
        initial_param_value = init_param+eps;
        
        

        [fading_data_linear,s,e,samples_ratio] = collect_neighbour_data(fading_linear_cell,i,min_samples,max_bin_size);
        range_start = s;
        range_end = e;
%         fading_data_linear = concat_cell(fading_linear_cell,range_start,range_end);
        if j==0
            initial_param_value = mle(fading_data_linear,'distribution','nakagami');
        else
            temp_index_start = max(1,s-1);
            initial_param_value = median(params(temp_index_start:j,:),1);
        end
        per_value = sum(per_stat(range_start:range_end,1).*samples_ratio(range_start:range_end)')./ sum(per_stat(range_start:range_end,2).*samples_ratio(range_start:range_end)');
        approximated_per(i)=per_value;
%         if isempty(fading_data_linear)
%             params(range_start:range_end,:)=nan;
%             continue;
%         end
        
        [params_res,loss] = mle_nakagami_truncated_variance_invariant_smooth(initial_param_value(1:2),fading_data_linear,per_value,truncation_value,.5);
        
        fprintf('kld loss %d:%d for bin %d : %d \n',range_start,range_end,i,loss)
        if show_dist
            histogram_samples_vs_dist(fading_data_linear,'lognakagami',params_res,10000,per_value,['Bin ',num2str(i),'Samples range ',num2str(range_start),':',num2str(range_end),' '])

            saveas(gcf,['Plots/',file_name,'/',log_histogram_folder_name,'/',num2str(i),'.png']);
            close gcf

%             histogram_samples_vs_dist(fading_data_linear,'nakagami',params_res,10000,per_value,['Bin',num2str(i),'Samples range ',num2str(range_start),':',num2str(range_end),' '])
% 
%             saveas(gcf,['Plots/',file_name,'/',histogram_folder_name,'/',num2str(i),'.png']);
%             close gcf
        end
        loss_values(i) = loss;
        if size(params_res,2) ==2
            params_res(3) =0;
        end
        params(i,:) =params_res;
%         params(range_start:range_end,:) = repmat(params_res,range_end-range_start+1,1);
%         params(range_start:range_end,3) = params(range_start:range_end,3).*fading_displacement(range_start:range_end)';
    end
    
end

