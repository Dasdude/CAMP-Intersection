function [signal_cell_dbm] = add_fading(pathloss,fading_dbm_cell,tx_power)
%INDUCE_FADING Summary of this function goes here
%   Detailed explanation goes here
signal_cell_dbm = cell(1,length(fading_dbm_cell));
    for i=1:length(signal_cell_dbm)
        signal_cell_dbm{i} = fading_dbm_cell{i}(:)+tx_power-pathloss(i);
    end
end

