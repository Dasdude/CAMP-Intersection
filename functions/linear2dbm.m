function [dbm_cell] = linear2dbm(linear_cell)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    if iscell(linear_cell)
        dbm_cell = cell(1,length(linear_cell));
        for i = 1:length(dbm_cell)
            dbm_cell{i} = 10*log10((linear_cell{i}.^2)*1000);
        end
    else
        dbm_cell = 10*log10((linear_cell.^2)*1000);
    end
end

