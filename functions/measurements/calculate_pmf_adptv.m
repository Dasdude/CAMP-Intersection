function [pmf,edges_lower,edges_upper] = calculate_pmf_adptv(data,total_bins_max)
%CALCULATE_PMF_ADPTV Summary of this function goes here
%   Detailed explanation goes here

total_samples = length(data);
total_bins = min(total_bins_max,max(floor(total_samples./8),2));
data_sorted = sort(data);
bin_width = ceil(total_samples./total_bins_max);

bin_pivot_index_lower = 1;
edges = zeros(1,total_bins_max)*nan;
lower_edges = zeros(1,total_bins_max)*nan;
upper_edges = zeros(1,total_bins_max)*nan;
edge_index = 1;
pmf = zeros(1,total_bins_max)*nan;
while bin_pivot_index_lower<=total_samples
%     lower_edges(edge_index) = data_sorted(bin_pivot_index_lower);
    edges(edge_index)=data_sorted(bin_pivot_index_lower);
    bin_pivot_index_upper=min(bin_pivot_index_lower+bin_width-1,total_samples);
    if data_sorted(bin_pivot_index_upper)== data_sorted(bin_pivot_index_upper-1)
        while bin_pivot_index_upper<=total_samples & data_sorted(bin_pivot_index_upper)== data_sorted(bin_pivot_index_upper-1)
            bin_pivot_index_upper=bin_pivot_index_upper+1;
        end
    end
    pmf(edge_index) =bin_pivot_index_upper-bin_pivot_index_lower+1;% for last bin to be the number of samples
    bin_pivot_index_lower=bin_pivot_index_upper+1;
    edge_index = edge_index+1;
end

pmf = pmf(1:edge_index-1);
edges = edges(1:edge_index-1);
pmf = pmf./sum(pmf);
pmf = [pmf,0];
edges_lower = [-inf,edges];
edges_upper = [edges,inf];
end

