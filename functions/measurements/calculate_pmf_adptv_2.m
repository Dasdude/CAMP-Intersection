function [pmf,lower_edges,upper_edges,center_edges] = calculate_pmf_adptv_2(data)
%CALCULATE_PMF_ADPTV Summary of this function goes here
%   Detailed explanation goes here

total_samples = length(data);
data_bins_unique = unique(data);
max_bins = length(data_bins_unique);
hist_unique = histogram(data,data_bins_unique);
count_list = hist_unique.Values;
samples_per_bin = max(hist_unique.Values);
cumsum_list = cumsum(count_list);
grabed_cumsum = samples_per_bin*[1:(int64(total_samples/samples_per_bin)+2)];
idx = find(grabed_cumsum>=total_samples,'first');
grabed_cumsum(idx) = total_samples;
grabed_cumsum = grabed_cumsum(grabed_cumsum<=total_samples);
max_bins = length(grabed_cumsum);
center_edges = zeros(1,max_bins)*nan;
pmf = grabed_cumsum;
for i = 1:length(grabed_cumsum)
    idx = find(cumsum_list>=grabed_cumsum(i),'first');
    r = cumsum_list(idx)-grabed_cumsum(i)./count_list(idx);
    if r~=0
        center_edges(i) = data_bins_unique(idx)*(1-r)+data_bins_unique(idx+1)*r;
    else
        center_edges(i) = data_bins_unique(idx)*(1-r);
    end
    
end
width_upper =(center_edges(2:end)-center_edges(1:end))/2
upper_edges = (center_edges(2:end)+center_edges(1:end))/2;
upper_edges = [upper_edges,inf]
lower_edges = [-inf,upper_edges(1:end-1)];

pmf = pmf./sum(pmf);

end

