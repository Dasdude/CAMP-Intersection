function [outputArg1,outputArg2] = per_roadmap_heatmap(data,dist_step,dist_window,plot_folder)
mkdir(plot_folder);
pl_sudo_val = -110
long_lim = [min(data.RxLon),max(data.RxLon)];

lat_lim = [min(data.RxLat),max(data.RxLat)];
lat_lim = [33.755,33.764];
long_lim = [-117.996,-117.984];
lat_flag = data.TxLat>lat_lim(1)&data.TxLat<lat_lim(2)&data.RxLat>lat_lim(1)&data.RxLat<lat_lim(2);
long_flag = data.TxLon>long_lim(1)&data.TxLon<long_lim(2)&data.RxLon>long_lim(1)&data.RxLon<long_lim(2);
inboundry_flag = lat_flag&long_flag;
data = data(inboundry_flag,:);
data.RSS(data.RSS>=999)=pl_sudo_val;
lat_step = 1e-4
long_step = 4e-4
data.TxLat = data.TxLat- mod(data.TxLat,lat_step);
data.RxLat = data.RxLat-mod(data.RxLat,lat_step);
data.TxLon = data.TxLon - mod(data.TxLon,long_step);
data.RxLon = data.RxLon - mod(data.RxLon,long_step);
result_table = cell2table(cell(0,7),'VariableNames',{'lat1','lon1','lat2','lon2','mean_rss','per','mean_rss_per_inc'});
% data_dist_fixed = data;
% format long g
for dist_iter = 50:dist_step:500
    min_dist = dist_iter;
    max_dist = dist_iter+dist_window;
    sel_flag  = data.TxRxDistance>min_dist&data.TxRxDistance<max_dist;
    data_dist_fixed = data(sel_flag,:);
    data = data(~sel_flag,:);
    total_samples = height(data_dist_fixed);
    while height(data_dist_fixed)>0
        lat_lon_pair =[data_dist_fixed.TxLat,data_dist_fixed.TxLon,data_dist_fixed.RxLat,data_dist_fixed.RxLon];
        lat_lon_pair2 = [data_dist_fixed.RxLat,data_dist_fixed.RxLon,data_dist_fixed.TxLat,data_dist_fixed.TxLon];
        pair1_flag = all((lat_lon_pair == lat_lon_pair(1,:))')';
        pair2_flag = all((lat_lon_pair2 == lat_lon_pair2(1,:))')';
        target_flags = pair1_flag|pair2_flag;
        data_capture = data_dist_fixed(target_flags,:);
        data_dist_fixed = data_dist_fixed(~target_flags,:);
        mean_val = mean(data_capture.RSS(data_capture.RSS~=pl_sudo_val));
        per_val = length(data_capture.RSS(data_capture.RSS==pl_sudo_val))./height(data_capture);
        mean_rss_per_inc  = mean(data_capture.RSS);
        result_table(height(result_table)+1,:) = array2table([lat_lon_pair(1,:),mean_val,per_val,mean_rss_per_inc]);
        clc
        sprintf('distance:%d ,%.0f/100',dist_iter,100*(1-(height(data_dist_fixed)/total_samples)))
    end
    if height(result_table)~=0
        p1_coor = [result_table.lat1,result_table.lon1];
        p2_coor = [result_table.lat2,result_table.lon2];
        color_vals = result_table.mean_rss_per_inc;
        title_str = sprintf('Mean RSS (Packet Loss RSS val %d) range %d to %d',pl_sudo_val,min_dist,max_dist);
        cbar_title = 'Mean RSS';
        plot_line_set_with_color(p1_coor,p2_coor,color_vals,title_str,cbar_title,[plot_folder,'RSS with PL/']);
        
        color_vals = result_table.mean_rss;
        title_str = sprintf('Mean RSS WO PL range %d to %d',min_dist,max_dist);
        cbar_title = 'Mean RSS';
        plot_line_set_with_color(p1_coor,p2_coor,color_vals,title_str,cbar_title,[plot_folder,'RSS wo PL/']);
        
        color_vals = result_table.per;
        title_str = sprintf('PER range %d to %d',min_dist,max_dist);
        cbar_title = 'PER';
        plot_line_set_with_color(p1_coor,p2_coor,color_vals,title_str,cbar_title,[plot_folder,'PER/']);
%         break
    end
%     figure('pos',[10,10,1024,768]);
%      min_rss = min(rss);
%         max_rss = max(rss);
%         total_colors = 100;
%         c_idx = int64((total_colors-1)*(rss - min_rss)/(max_rss-min_rss))+1;
%         a = colormap(jet(100));
%     for i = 1:height(result_table)
%         hold on 
%         line_properties = result_table(i,:);
%         
%     end
end
% for lat_iter = lat_lim(1):lat_step:lat_lim(2)
%     for long_iter = long_lim(1):long_step:long_lim(2)
%         
%     end
% end
end

