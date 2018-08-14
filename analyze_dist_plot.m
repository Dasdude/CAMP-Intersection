addpath(genpath('.'))
clc
close all
% clear
lon_lim = [-117.993,-117.987]
lat_lim = [33.757,33.761];
sq_vertice = [33.759453,-117.989372;
              33.759423,-117.990004;
              33.759121,-117.989391;
              33.759104,-117.989955];
file_name = 'dif_leg_los';
data_path = sprintf('./Dataset/Ehsan/%s.csv',file_name);
plot_folder = sprintf('./Plots/AnalyzeMap/%s/',file_name);
mkdir(plot_folder);
data_table = readtable(['./Dataset/Ehsan/',file_name,'.csv'],'ReadVariableNames',true);
% data_table = nlos_data;
% data_table = same_leg_data;
color_total_bins = 100;
colormap_jet = jet(color_total_bins);
d  = 0:50:500;
for d= 50:5:500
    
    data_temp_all = data_table(floor(data_table.TxRxDistance)==d,:);
    data_temp_all = data_temp_all(data_temp_all.RSS~=999,:);
    idx = randsample(height(data_temp_all),min(height(data_temp_all),1000));
    data_temp = data_temp_all(idx,:);
    sprintf('distance %d Total data %d',d,height(data_temp_all)) 
    tr = [data_temp.TxLon,data_temp.TxLat];
    rec = [data_temp.RxLon,data_temp.RxLat];
    rss = data_temp.RSS;
    rss = rss(rss~=999);
    rss = floor(rss);
    min_rss = -100;
    max_rss = -40;
%     lat_lim = [min(tr(:,2)),max(tr(:,2))];
%     lon_lim = [min(tr(:,1)),max(tr(:,1))];
    total_colors = max_rss-min_rss+1;
    if isempty(total_colors)
        continue
    end
    colormap_jet = jet(total_colors);
    color_index = rss-min_rss+1;
    set(gcf, 'Position', get(0, 'Screensize'),'Visible','off')
    figure;
    set(gcf, 'Position', get(0, 'Screensize'),'Visible','off')
%     subplot(2,1,1);
    title(sprintf('Road Map RSS based distance:%d',d))
    caxis([min_rss,max_rss])
    xlabel('long')
    ylabel('lat')
    xlim(lon_lim)
    ylim(lat_lim)   
    lat = [lat_lim(1),lat_lim(2),lat_lim(1),lat_lim(2)];

    lon = [lon_lim(1),lon_lim(2),lon_lim(1),lon_lim(2)]; 
    % lon = [2.4131 -0.1300 12.4951 -3.6788 13.415 23.715]; 
     
     hold on
    for i = 1:length(rec(:,1))
        hold on
        tr_cor = [tr(i,:);rec(i,:)];
        clr_index = color_index(i);
        set(gcf, 'Position', get(0, 'Screensize'),'Visible','off')
        plot(tr_cor(:,1),tr_cor(:,2),'Color',colormap_jet(clr_index,:));
        hold on 
    end
    scatter(sq_vertice(:,2),sq_vertice(:,1),1000,'.','r')

    hold on
%     plot_google_map('MapScale', 1,'MapType','satellite')    
    
%     set(gcf, 'Position', get(0, 'Screensize'),'Visible','off')
    colormap jet
%     scatter(tr(:,1),tr(:,2),5,rss);
%     scatter(rec(:,1),rec(:,2),5,rss);
    colorbar('Ticks',[min_rss:10:max_rss])
    saveas(gcf,[plot_folder,num2str(d),'_lines.png'])
    figure;
%     subplot(2,1,2);
    histogram(data_temp_all.RSS,'Normalization','probability');
    xlabel('RSS')
    title(sprintf('RSS Distribution distance:%d',d));
%     suptitle(sprintf('%d meter Distance',d));
    
    set(gcf, 'Position', get(0, 'Screensize'),'Visible','off')
    saveas(gcf,[plot_folder,num2str(d),'_hist.png'])
    
%     tr = [data_temp_all.TxLat,data_temp_all.TxLon];
%     rec = [data_temp_all.RxLat,data_temp_all.RxLon];
%     rss = data_temp_all.RSS;
%     figure;
%     set(gcf, 'Position', get(0, 'Screensize'),'Visible','off')
%     length(tr(:,1))
%     scatter(tr(:,1),tr(:,2),10,rss);
%     hold on
%     scatter(rec(:,1),rec(:,2),10,rss);
%     colorbar()
%     xlabel('lat')
%     ylabel('long')
%     title(sprintf('Road Map RSS distance %d',d))
%     saveas(gcf,[plot_folder,num2str(d),'_scatter.png'])
    close all
%     saveas(gcf,[plot_folder,num2str(d),'.fig'])
    
end