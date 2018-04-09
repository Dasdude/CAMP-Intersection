function [res] = funoncellarray1input(cell_array1,fun)
%FUNONCELLARRAY Summary of this function goes here
%   Detailed explanation goes here
    res = zeros(1,length(cell_array1))*nan;
    for i=1:length(cell_array1)
        if isempty(cell_array1{i})
            continue;
        end
        res(i)=fun(cell_array1{i});
    end
end

