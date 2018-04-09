function [samples_1_percentiles] = percentile_array(percentile_array,samples_1)
%PERCENTILE_PLOT Summary of this function goes here
%   Detailed explanation goes here
total_percentile = length(percentile_array);
samples_1_percentiles = zeros(length(samples_1),total_percentile);
for i = 1:total_percentile
    fun_handle = @(x)prctile(x{1},percentile_array(i));
    res = funonarray(fun_handle,{samples_1});
    samples_1_percentiles(:,i) = res';
end
end

