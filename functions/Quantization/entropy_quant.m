function [ent] = entropy_quant(data,n_bins)
%ENTROPY_QUANT Summary of this function goes here
%   Detailed explanation goes here
n_bins_int = floor(n_bins);
r = n_bins-n_bins_int;
[data_pmf_1,edge_lower_1] = calculate_pmf_adptv(data,2^n_bins_int);
ent1 = -sum(data_pmf_1.*log2(data_pmf_1+eps));
[data_pmf_2,edge_lower_2] = calculate_pmf_adptv(data,2^(n_bins_int+1));
ent2 = -sum(data_pmf_2.*log2(data_pmf_2+eps));
bins_1 = size(edge_lower_1,2);
bins_2 = size(edge_lower_2,2);
% ent1 = -ent1/log2(bins_1);
% ent2 = -ent2/log2(bins_2);
ent = (r*ent1)+((1-r)*ent2);
end

