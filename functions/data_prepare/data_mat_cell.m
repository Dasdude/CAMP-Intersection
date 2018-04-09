function [dataset_cell] = data_mat_cell(dataset,d_max)
%   dataset should be Samples x (range,RSSI) (Nx2)
%   returns cell array with size (1,d_max)
    dataset_cell  = cell(d_max,1);
    [r,IX]=sort(dataset(:,1));
    dataset(:,1)=r;
    dataset(:,2)=dataset(IX,2);
    lower = 1;
    for i= 1:d_max
        upper = find(dataset(:,1)<i+1,1,'last');
        dataset_cell{i}=dataset(lower:upper,2);
        lower = upper+1;
    end
end

