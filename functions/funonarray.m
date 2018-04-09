function [res] = funonarray(fun_handle,x)
%FUNONARRAY Summary of this function goes here
%   x should be cell array with each cell being an input, fun_hanle should
%   get a cell array
    input1 = x{1};
    if iscell(input1)
        iteration_length = length(input1);
    else
        iteration_length = size(input1,1);
    end
    res = zeros(1,iteration_length)*nan;
    for i = 1:iteration_length
        input_cell = cell(length(x),1);
        for j = 1:length(x)
            if iscell(x{j})
                input_cell{j} = x{j}{i};
            else
                input_cell{j} = x{j}(i,:);
            
            end
        end
        res(i)=fun_handle(input_cell);
    end
end

