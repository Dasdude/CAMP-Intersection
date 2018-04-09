function [dataset_cell_res] = truncate_data_cell(dataset_cell,truncate_val)
%TRUNCATE_DATA_CELL removes values from dataset which are less than
%truncated_val
%   Detailed explanation goes here
    dataset_cell_res = cell(length(dataset_cell),1);

    for i = 1:length(dataset_cell)
        data_temp = dataset_cell{i};
        dataset_cell_res{i} = data_temp(data_temp>truncate_val);
    end
end

