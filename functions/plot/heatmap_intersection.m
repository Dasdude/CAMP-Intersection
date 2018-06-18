clc
close all

sq_long_lim = [-117.990004,-117.989372];
sq_lat_lim = [33.759104,33.759453];
lon_lim = [-117.993,-117.987];
lat_lim = [33.757,33.761];
sq_vertice = [33.759453,-117.989372;
              33.759423,-117.990004;
              33.759121,-117.989391;
              33.759104,-117.989955];
data_table = readtable(['./Dataset/Ehsan/',file_name,'.csv'],'ReadVariableNames',true);
file_name = 'nlos2';
data_path = sprintf('./Dataset/Ehsan/%s.csv',file_name);
plot_folder = sprintf('./Plots/AnalyzeMap/HeatMap/%s/',file_name);
mkdir(plot_folder);
data_table = data_table(data_table.RSS<999,:);
[idx_range,edges_range] = discretize(data_table.TxRxDistance,1000);
data_table.RxLatdis = discretize(data_table.RxLat,100);
data_table.RxLondis=    discretize(data_table.RxLon,100);
data_table.TxRxDistancetmp = edges_range(idx_range)';

for idx_d = 1:length(edges_range)
    
    distance = edges_range(idx_d);
    data_table_tmp = data_table(data_table.TxRxDistancetmp==distance,:);
    
    figure;
    heatmap(data_table_tmp , 'RxLatdis','RxLondis','ColorVariable','RSS','Colormap',jet);
    title(['Heat Map of RSS based on Receiver Location for Distance',num2str(distance)]);
    saveas(gcf,[plot_folder,num2str(distance),'_heatmap.png'])
end
close all
% for d = 1:20:500
%     
% end
%% Horizontal wings 
% long_1 = linspace(long_lim(1),sq_long_lim(1),10);
% long_2 = linspace(sq_long_lim(2),long_lim(2),10);
% lat_1 = linspace(lat_lim(1),sq_lat_lim(1),10);
% lat_2 = linspace(sq_lat_lim(2),lat_lim(2),10);
% figure
% for base_idx = 1:length(lat_1)-1
%     flag = data_table.RxLat>lat_1(base_idx)&data_table.RxLat<lat(base_idx+1);
%     flag = flag|(data_table.TxLat>lat_1(base_idx)&data_table.TxLat<lat(base_idx+1));
%     data_table_base = data_table(flag,:);
%     for i = 1:length(lat_1)-1
%         flag_target = data_table.RxLat>lat_1(i)&data_table.RxLat<lat(i+1);
%         flag_target = flag_target|(data_table.TxLat>lat_1(i)&data_table.TxLat<lat(i+1));
%         data_table_target = data_table_base(flag_target,:);
%         value_mean = mean(data_table_target.RSS);
%         value_std = std(data_table_target.RSS);
%     end
%     heatmap
% end
