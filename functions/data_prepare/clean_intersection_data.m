function [data_table_res] = clean_intersection_data(data_table)
%CLEAN_INTERSECTION_DATA Summary of this function goes here
%   Detailed explanation goes here
data_rxlat = data_table.RxLat;
data_rxlon = data_table.RxLon;
data_txlat = data_table.TxLat;
data_txlon = data_table.TxLon;
leftwing_flag = data_rxlat>33.7585|data_rxlat<33.7595;
soutwing_flag = data_rxlon>-117.990|data_rxlon<-117.987;
long_range = [-117.990,-117.989];
lat_range = [33.759,33.7595];
% lat_range = [min(data_rxlat(soutwing_flag)),max(data_rxlat(soutwing_flag))];
hor_flag = data_txlat>lat_range(1) & data_txlat<lat_range(2);
ver_flag = data_txlon>long_range(1)&data_txlon<long_range(2);
sel_flag = hor_flag|ver_flag;
data_table_res = data_table(sel_flag,:);
figure;
scatter(data_table.TxLat,data_table.TxLon,1);
title('Transmitter prev')
figure;
scatter(data_table_res.RxLat,data_table_res.RxLon,1);
title('Receiver')
figure;
scatter(data_table_res.TxLat,data_table_res.TxLon,1);
title('Transmitter')
end

