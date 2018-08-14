function [] = plot_roadmap_transreciev(data_table,total_max_lines,folder_name,include_pl)
    LAT_LIM = [33.755,33.764];
    LONG_LIM = [-117.996,-117.984];
    
    if include_pl
        data_table = data_table(data_table.RSS<999,:);    
    end
    data_table.RSS(data_table.RSS>=999) = -100;
    distance_bin_size = 20;
    plot_folder_path = ['./Plots/DataAnalysis/',folder_name,'/'];
    mkdir(plot_folder_path);
    colormap jet
    for d = distance_bin_size:distance_bin_size:500
        data_table_sub = data_table(data_table.TxRxDistance<d&data_table.TxRxDistance>d-distance_bin_size,:);
        if height(data_table_sub)==0
            continue
        end
        total_lines = min(total_max_lines, height(data_table_sub));
        idx = randsample(height(data_table_sub),min(height(data_table_sub),total_max_lines));
        x= table2array([data_table_sub(idx,'TxLat'),data_table_sub(idx,'TxLon')]);
        y= table2array([data_table_sub(idx,'RxLat'),data_table_sub(idx,'RxLon')]);
        rss = table2array(data_table_sub(idx,'RSS'));
        figure('pos',[10 10 1024 768]);
        min_rss = min(rss);
        max_rss = max(rss);
        total_colors = 100;
        c_idx = int64((total_colors-1)*(rss - min_rss)/(max_rss-min_rss))+1;
        a = colormap(jet(100));
        for i = 1:length(x(:,1))
            subplot(2,1,1)
            hold on
            tr_cor = [x(i,:);y(i,:)];
            plot(tr_cor(:,1),tr_cor(:,2),'Color',a(c_idx(i),:));
            grid on
            hold on 
        end
        c = colorbar;
        caxis([min_rss,max_rss]);
        c.Limits = [min_rss,max_rss];
        c.Ticks = [min_rss:5:max_rss];
        title(sprintf('RSS values for Range %d:%d',d-distance_bin_size,d));
        xlim(LAT_LIM);
        ylim(LONG_LIM);
        xlabel('Lat')
        ylabel('Long')
        ylabel(c,'RSS')
        subplot(2,1,2);
        histogram(rss)
        xlabel('RSS')
        
        saveas(gcf,sprintf('%s%d-%d.jpg',plot_folder_path,d-distance_bin_size,d));
        close all
        
    end
end

