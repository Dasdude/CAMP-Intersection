function [data_mat] = data_cell2mat(data_cell)
%DATA_CELL2MAT Summary of this function goes here
%   Detailed explanation goes here
    total_entries = 0;
    for i= 1:length(data_cell)
        total_entries = total_entries+length(data_cell{i});
    end
    data_mat = zeros(total_entries,2);
    lower = 1;
    for i = 1:length(data_cell)
        if isempty(data_cell{i})
            continue;
        end
        upper = lower+length(data_cell{i})-1;
        data_mat(lower:upper,2) = data_cell{i};
        data_mat(lower:upper,1) = i;
        lower = upper+1;
    end
end

