function [kld_result] = kld_samples(gt_ds,ds,total_bins)
%KLD Summary of this function goes here
%% KLD
try
[data_pmf,lower_edge,upper_edge]= calculate_pmf_adptv([gt_ds;ds],total_bins);
pmf_gt = histcounts(gt_ds,lower_edge,'Normalization','probability');
pmf_target =histcounts(ds,lower_edge,'Normalization','probability');
kld_result = (-sum(pmf_gt.*log2(pmf_target+eps)) + sum(pmf_gt.*log2(pmf_gt+eps)));
catch
   kld_result=nan;
   kld_result;
end

end

