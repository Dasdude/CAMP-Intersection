function [] = plot_line_set_with_color(p1_coor,p2_coor,color_vals,title_str,cbar_label,path_save)
%PLOT_LINE_SET_WITH_COLOR Summary of this function goes here
%   Detailed explanation goes here
mkdir(path_save);
 LAT_LIM = [33.755,33.764];
    LONG_LIM = [-117.996,-117.984];
figure('pos',[10 10 1024 768]);
subplot(2,1,1)
min_val = min(color_vals);
max_val = max(color_vals);
if min_val == max_val
    max_val = max_val+1;
end
color_quant_ttl = 100;
c_idx = int64((color_quant_ttl-1)*(color_vals - min_val)/(max_val-min_val))+1;
cmap_jet = colormap(jet(color_quant_ttl));
for i = 1:size(p1_coor,1)
    hold on
    tr_cor = [p1_coor(i,:);p2_coor(i,:)];
    plot(tr_cor(:,1),tr_cor(:,2),'Color',cmap_jet(c_idx(i),:));
    grid on
end
cbar = colorbar;
caxis([min_val,max_val]);
cbar.Limits = [min_val,max_val];
cbar.Ticks = linspace(min_val,max_val,10);
title(title_str);
xlim(LAT_LIM);
ylim(LONG_LIM);
xlabel('Lat');
ylabel('Long');
ylabel(cbar,cbar_label);
subplot(2,1,2)
histogram(color_vals);
xlabel(cbar_label);
ylabel('Samples');
saveas(gcf,[path_save,title_str,'.jpg'])
end

