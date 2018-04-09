function [pmf,edges_center,mean_data,std_data] = cdf2pmf(cdf,edges)
%CDF2PMF Summary of this function goes here
%   supports truncated cdf, calculates truncated mean and std, Edges should
%   be uniform
d_xmesh = edges(2)-edges(1);
data_cdf_upper_trunc = [cdf(2:end),cdf(end)];
pmf = data_cdf_upper_trunc - cdf;
pmf(pmf<0)=eps;
edges_center = edges+(d_xmesh./2);
mean_data =  sum(pmf.*(edges_center));
std_data = sqrt(sum((pmf.*(edges_center-mean_data)).^2));
end

