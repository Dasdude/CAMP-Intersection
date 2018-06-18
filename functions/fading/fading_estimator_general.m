function [params,bin_start_edges,approximated_per,loss_values] = fading_estimator_general(fading_linear_cell,dist_handle_object,per_stat,min_samples,max_window_size,file_name,show_dist,min_samples_per_cell)
%FADING_ESTIMATOR_NAKAGAMI_SET Summary of this function goes here
%   Detailed explanation goes here
%FADING_ESTIMATOR_NAKAGAMI_MLE_ADPTV_BIN Summary of this function goes here
%   Detailed explanation goes here
    bin_size=1;
    max_bin_size = max_window_size;
    params = zeros(length(fading_linear_cell),dist_handle_object.get_dof())*nan; % R x 3 : Range x [mu,omega,bias]
    log_histogram_folder_name = 'log nakagami estimate dist histograms';
    histogram_folder_name = 'nakagami estimate dist histograms';
    mkdir(['Plots/',file_name,'/',histogram_folder_name]);
    mkdir(['Plots/',file_name,'/',log_histogram_folder_name]);
    per_list = per_stat(:,1)./per_stat(:,2);
    %%
    bin_start_edges = (1:bin_size:length(fading_linear_cell))*0;
    bin_end_edges = (1:bin_size:length(fading_linear_cell))*0;
    bin_mid_edges = (1:bin_size:length(fading_linear_cell))*0;
    d_max = length(fading_linear_cell);
    
    %%
    approximated_per = zeros(1,d_max);
    loss_values = zeros(1,d_max)*nan;
    prev_bin = [0,0];
    for i = 1:length(fading_linear_cell)
        j=i-1;

        [fading_data_linear,s,e,samples_ratio] = collect_neighbour_data_set(fading_linear_cell,i,min_samples,max_bin_size,min_samples_per_cell);
        range_start = s;
        range_end = e;
        bin_start_edges(i) = s;
        bin_end_edges(i)=e;
        bin_mid_edges(i)=i;
        if j==0
            initial_param_value = mle(fading_data_linear,'distribution',dist_handle_object.dist_name);
        else
            temp_index_start = max(1,j-20);
            initial_param_value = mean(params(temp_index_start:j,:),1);
        end
        per_value = sum(per_stat(range_start:range_end,1))./ sum(per_stat(range_start:range_end,2));
        approximated_per(i)=per_value;
        if all(prev_bin == [s,e])
            params_res = params(i-1,:);
            loss=loss_values(i-1);
        else
            if length(fading_linear_cell{i}>20) || i==1
                [params_res,loss] = mle_set(initial_param_value(:),fading_linear_cell(s:e),per_list(s:e),i-s+1,dist_handle_object);
            else
                params_res = params(i-1,:);
            end
        end
        fprintf('kld loss %d:%d for bin %d : %d \n',s,e,i,loss)
        if show_dist
            histogram_samples_vs_dist(fading_linear_cell{i},dist_handle_object,params_res,10000,per_list(i),['Bin ',num2str(i),'Samples range ',num2str(range_start),'(m):',num2str(range_end),'(m) '])
            saveas(gcf,['Plots/',file_name,'/',log_histogram_folder_name,'/',num2str(i),'.png']);
            close all
        end
        loss_values(i) = loss;
%         if size(params_res,2) ==2
%             params_res(3) =0;
%         end
        params(i,:) =params_res;
        prev_bin = [s,e];
%         params(range_start:range_end,:) = repmat(params_res,range_end-range_start+1,1);
%         params(range_start:range_end,3) = params(range_start:range_end,3).*fading_displacement(range_start:range_end)';
    end
    
end

