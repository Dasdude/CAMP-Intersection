function [] = plot_roadmap_transreciev(data_table,total_max_lines)
    idx = randsample(height(data_table),min(height(data_table),total_max_lines));
    x= table2array([data_table(idx,'TxLat'),data_table(idx,'TxLon')]);
    y= table2array([data_table(idx,'RxLat'),data_table(idx,'RxLon')]);
    figure;
    for i = 1:length(x(:,1))
        hold on
        tr_cor = [x(i,:);y(i,:)];
    plot(tr_cor(:,1),tr_cor(:,2));
    hold on 
    end
end

