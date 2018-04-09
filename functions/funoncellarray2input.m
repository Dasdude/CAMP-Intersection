function [res] = funoncellarray2input(cell_array1,cell_array2,fun)
%FUNONCELLARRAY Summary of this function goes here
%   Detailed explanation goes here
    res = zeros(1,length(cell_array1))*nan;
    for i=1:length(cell_array1)
        if isempty(cell_array1{i}) | isempty(cell_array2{i})
            continue;
        end
        res(i)=fun(cell_array1{i},cell_array2{i});
    end
end

