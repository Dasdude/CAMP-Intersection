function [outputArg1,outputArg2] = per_plot(per,d_min,d_max,plot_name,folder_name)
%PER_PLOT Summary of this function goes here
%   Detailed explanation goes here

figure('Visible','off');
plot(per);
title(plot_name);
xlabel('Range');
ylabel('PER Values');
xlim([d_min,d_max])
ylim([0,1]);
saveas(gcf,['Plots/',folder_name,'/',plot_name,'.png']);
end

