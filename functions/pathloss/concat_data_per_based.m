function [data_cell_expand] = concat_data_per_based(data_cell,per,trunc_val)
%CONCAT_DATA_PER_BASED Summary of this function goes here
%   Detailed explanation goes here
    data_cell_expand = cell(size(data_cell));
    per_no_nan = per;
    per_no_nan(isnan(per_no_nan))=0;
    for i = 1:length(data_cell)
        samples_length = length(data_cell{i});
        concat_length = int64(samples_length*(per_no_nan(i))./(1-per_no_nan(i)));
        data_concat = ones(concat_length,1)*trunc_val;
        data_cell_expand{i} = [data_cell{i};data_concat];
    end
    
end

