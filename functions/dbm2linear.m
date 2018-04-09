function [linear_cell] = dbm2linear(dbm_cell)
%DBM2LINEAR Summary of this function goes here
%   Detailed explanation goes here
    if iscell(dbm_cell)
        linear_cell = cell(1,length(dbm_cell));
        for i = 1:length(dbm_cell)
            if(any(isnan(dbm_cell{i})))
                dbm_cell
            end
            linear_cell{i} = sqrt((10.^(dbm_cell{i} ./ 10))./1000);
            if(any(isnan(linear_cell{i})))
                linear_cell{i}
            end
        end
    else
        linear_cell = sqrt((10.^(dbm_cell ./ 10))./1000);
    end
end

