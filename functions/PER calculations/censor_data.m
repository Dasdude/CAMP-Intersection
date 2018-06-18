function [data_censored,per,packet_loss_stat] = censor_data(dataset_cell,censor_function_handle)
%CENSOR_DATA censors the dataset which is a cell array (each cell for a
%distance) with the censor function with one input which is an array of
%values
    data_censored = cell(1,length(dataset_cell));
    per = zeros(size(1,length(dataset_cell)));
    packet_loss_stat = zeros(length(dataset_cell),2);
        for i=1:length(dataset_cell)
            mat_data  = dataset_cell{i};
            [data_censor,per_val,packet_loss_stat_val] = censor_function_handle(mat_data);
            data_censored{i}=data_censor;
            per(i) = per_val;
            packet_loss_stat(i,:) = packet_loss_stat_val;
        end
end


