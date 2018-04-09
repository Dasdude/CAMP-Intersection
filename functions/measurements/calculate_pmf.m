function [pdf,edges] = calculate_pmf(ds,min_probability_flag,edges)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [pdf_ds,edges] = hist(ds,edges);
    if min_probability_flag==1
        pdf_ds(pdf_ds<eps)=eps;
    end
    pdf = pdf_ds(:)./sum(pdf_ds(:));

end

