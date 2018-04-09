function [packet_loss_stat] = per_calc(dataset_cell,packet_drop_rssi)
%   returns packet loss stats rx2 , range x [lost_packets,total_packets]
%   cleans data afterward ( removes entries less than packet_drop_rssi
    packet_loss_stat = zeros(length(dataset_cell),2);
    for i = 1:length(dataset_cell)
        rssi_set = dataset_cell{i};
        packet_loss_stat(i,2) = length(rssi_set);
        packet_loss_stat(i,1) = length(rssi_set(rssi_set<packet_drop_rssi));
        dataset_cell{i} = dataset_cell{i}(rssi_set>packet_drop_rssi,:);
    end
end

