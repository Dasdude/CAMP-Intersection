function [fading_cell_dbm] = extract_fading(dataset_cell,pathloss,TX_POWER)
%EXTRCT_FADING Summary of this function goes here
%   Detailed explanation goes here
    fading_cell_dbm = cell(1,length(dataset_cell));
    for i=1:length(dataset_cell)
        fading_cell_dbm{i} = dataset_cell{i}(:)-TX_POWER+pathloss(i);
    end
end

