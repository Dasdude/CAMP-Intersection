function [kld_result] = kld_with_plot(gt_ds,ds,d_min,d_max,plot_name,folder_name)
%KLD Summary of this function goes here
% ds size = (N,2)  [Range , RSSI] 
% Fix this bin edges have problems. get edges_size as input
%% KLD
    kld_result = zeros(d_max,1)*nan;
    lower_gt = find(gt_ds(:,1)>=d_min,1,'first');
    lower_target = find(ds(:,1)>=d_min,1,'first');
    for i = d_min+1:d_max+1
        upper_gt = find(gt_ds(:,1)<i,1,'last');
        upper_target = find(ds(:,1)<i,1,'last');
        gt_dist = gt_ds(lower_gt:upper_gt,2);
        target_dist = ds(lower_target:upper_target,2);
        if isempty(target_dist) || isempty(gt_dist)||all(isnan(target_dist))||all(isnan(gt_dist))
            kld_result(i)=nan;
%             disp(['No samples for target or field test at range ',num2str(i)])
            lower_gt = upper_gt;
            lower_taget = upper_target; %#ok<NASGU>
            continue;
        end
        
        binEdges = [-inf;sort(gt_dist);inf];
        
        gt_hist = histc(gt_dist,binEdges);
        target_hist = histc(target_dist,binEdges);
        if size(gt_hist,2)>1
           gt_hist = gt_hist';
        end
        if size(target_hist,2)>1
            target_hist = target_hist';
        end
        gt_pdf = gt_hist./sum(gt_hist);
        target_pdf = target_hist./sum(target_hist);
        bitdif = gt_pdf.*log2((gt_pdf./(target_pdf+eps))+eps);
        kld_result(i) = sum(bitdif);
        lower_gt = upper_gt;
        lower_taget = upper_target; %#ok<NASGU>
    end
    figure('Visible','on');
    plot(kld_result);
    title(plot_name);
    xlabel('Range');
    ylabel('Average #bit difference');
    ylim([0,20]);
    saveas(gcf,['Plots/',folder_name,'\',plot_name,'.png']);

end

