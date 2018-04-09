function [res] = truncate_data_cell(data_cell,trunc_val)
%TRUNCATE_DATA_CELL Summary of this function goes here
%   Detailed explanation goes here
res = cell(size(1,length(data_cell)));
    for i=1:length(data_cell)
        mat_data  = data_cell{i};
        res{i}=mat_data(mat_data>trunc_val);
    end
end

