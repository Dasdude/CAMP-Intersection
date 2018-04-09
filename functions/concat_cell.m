function [res] = concat_cell(data_cell,range_start,range_end)
%CONCAT_CELL Summary of this function goes here
%   Detailed explanation goes here
    res =[];
    for i = range_start:range_end
        res = [res;data_cell{i}];
    end
end

