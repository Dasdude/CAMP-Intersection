function [samples_1_percentiles] = percentile_array_per(percentile_array,samples_1,per_array)
%PERCENTILE_PLOT Summary of this function goes here
%   Detailed explanation goes here
per_array = per_array;
total_percentile = length(percentile_array);
samples_1_percentiles = zeros(length(samples_1),total_percentile);
for d=  1:length(samples_1)
    
    new_percentile_array = 100*(percentile_array-per_array(d))./(100-per_array(d));
    for p_idx =1:length(new_percentile_array)
        if new_percentile_array(p_idx)<=0 || new_percentile_array(p_idx)>=100
            samples_1_percentiles(d,p_idx) = nan;
        else
            samples_1_percentiles(d,p_idx) = prctile(samples_1{d},new_percentile_array(p_idx));
        end
    end
end
% for i = 1:total_percentile
%     fun_handle = @(x)prctile(x{1},percentile_array(i));
%     res = funonarray(fun_handle,{samples_1});
%     samples_1_percentiles(:,i) = res';
% end
end

