function [std_val,mean_val] = std_mean_pdf_truncated(pdf_obj,trunc_pdf_rate)
%STD_MEAN_PMF Summary of this function goes here
%   Detailed explanation goes here
    trunc_val = icdf(pdf_obj,trunc_pdf_rate);
    max_bound = icdf(pdf_obj,.999);
    edges = linspace(trunc_val,max_bound,10000);
    edges_lower = edges(1:end-1);
    edges_upper = edges(2:end);
    edges_center = (edges_lower+edges_upper)./2;
    lower_cdf = cdf(pdf_obj,edges_lower);
    upper_cdf = cdf(pdf_obj,edges_upper);
    pmf = upper_cdf-lower_cdf;
    mean_val = sum(pmf(:).*edges_center(:));
    shift_val = edges_center-mean_val;
    std_val  = sqrt(sum(pmf(:).*(shift_val(:).^2)));
end

