function [los_flag] = get_typical_los(data_table)
%CLEAN_INTERSECTION_DATA Summary of this function goes here
%   Detailed explanation goes here
data_rxlat = data_table.RxLat;
data_rxlon = data_table.RxLon;
data_txlat = data_table.TxLat;
data_txlon = data_table.TxLon;
leftwing_flag = data_rxlat<33.758|data_rxlat>33.76;
soutwing_flag = data_rxlon<-117.991|data_rxlon>-117.988;
long_range = [min(data_rxlon(leftwing_flag)),max(data_rxlon(leftwing_flag))];
lat_range = [min(data_rxlat(soutwing_flag)),max(data_rxlat(soutwing_flag))];
hor_flag = data_txlat>lat_range(1) & data_txlat<lat_range(2)&data_rxlat>lat_range(1) & data_rxlat<lat_range(2);
ver_flag = data_txlon>long_range(1) & data_txlon<long_range(2)&data_rxlon>long_range(1) & data_rxlon<long_range(2);
los_flag = ver_flag|hor_flag;
% nlos_flag = ~los_flag;
% hor_flag = data_txlat>lat_range(1) & data_txlat<lat_range(2);
% ver_flag = data_txlon>long_range(1)&data_txlon<long_range(2);
% sel_flag = hor_flag|ver_flag;
clear data_rxlat
clear data_rxlon
clear data_txlat
clear data_txlon
clear ver_flag
% clear los_flag
clear hor_flag
clear leftwing_flag
clear soutwing_flag
% data_table_los = data_table(los_flag,:);
% data_table_nlos = data_table(~los_flag,:);
% x = [data_table_los.RxLat,data_table_los.RxLon];
% y = [data_table_los.TxLat,data_table_los.TxLon];
% for i = 1:length(x(:,1))
%     hold on
%     tr_cor = [x(i,:);y(i,:)];
% plot(tr_cor(:,1),tr_cor(:,2));
% hold on 
% end
% figure;
% scatter(data_table.TxLat,data_table.TxLon,1);
% title('Transmitter prev')
% figure;
% scatter(data_table_res.RxLat,data_table_res.RxLon,1);
% title('Receiver')
% figure;
% scatter(data_table_res.TxLat,data_table_res.TxLon,1);
% title('Transmitter')
end

