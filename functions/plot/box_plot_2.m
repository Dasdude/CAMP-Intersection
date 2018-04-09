function [] = box_plot_2(dist1,dist2,dist1_name,c1,dist2_name,c2,d_min,d_max,general_title,file_name,bin_size,show)
%BOX_PLOT Summary of this function goes here
%   Detailed explanation goes here
bin_size=10;
scrsz = get(groot,'ScreenSize');
figure('Position',[1 1 1920 1080],'Visible',show)

% ylim([-100 -40])
legend(dist1_name,dist2_name);
lower = find(dist1(:,1)<=d_min-1,1,'last');
upper = find(dist1(:,1)<=d_max,1,'last');
ax1 = boxplot(dist1(:,2),floor(dist1(:,1)/bin_size)*bin_size,'plotstyle','compact','colors',c1,'outliersize',10^-10);
hold
ax2= boxplot(dist2(:,2),floor(dist2(:,1)/bin_size)*bin_size,'plotstyle','compact','colors',c2,'outliersize',10^-10);
xlabel('Distance')
ylabel('RSSI')
title([dist1_name,c1,' vs ',dist2_name,c2,' ',general_title])
legend(dist1_name,dist2_name);
hold off

saveas(gcf,['Plots/',file_name,'/',general_title,dist1_name,c1,' vs ',dist2_name,c2,' ',general_title,'1.png'])

scrsz = get(groot,'ScreenSize');
figure('Position',[1 1 1920 1080],'Visible',show)

% ylim([-100 -40])

lower = find(dist1(:,1)<=d_min-1,1,'last');
upper = find(dist1(:,1)<=d_max,1,'last');
ax1 = boxplot(dist2(:,2),floor(dist2(:,1)/bin_size)*bin_size,'plotstyle','compact','colors',c2,'outliersize',10^-10);
hold
ax2= boxplot(dist1(:,2),floor(dist1(:,1)/bin_size)*bin_size,'plotstyle','compact','colors',c1,'outliersize',10^-10);
xlabel('Distance')
ylabel('RSSI')
title([dist1_name,' ',c1,' vs ',dist2_name,' ',c2,' ',general_title])
legend(dist2_name,dist1_name);
hold off

saveas(gcf,['Plots/',file_name,'/',general_title,' ',dist1_name,' ',c1,' vs ',dist2_name,' ',c2,' ',general_title,'2.png'])
end

