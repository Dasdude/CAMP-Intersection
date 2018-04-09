function [] = fading_plot(fading,title_name,file_name,d_max)
%FADING_PLOT Summary of this function goes here
%   Detailed explanation goes here
fds=fading;
range_quantization_par = 1;
range_iter = 0:range_quantization_par:d_max;

linear_fds_temp  = fds;
hist_range = min(linear_fds_temp(:,2)):max(linear_fds_temp(:,2));
linear_fds_temp(:,1) = floor(linear_fds_temp(:,1)/range_quantization_par)*range_quantization_par;
[range_mesh,bin_mesh] = meshgrid(range_iter,hist_range);
pdf_concat=[];
cmap_concat = [];

for i=range_iter
    index = linear_fds_temp(:,1)==i;
    ddr = linear_fds_temp(index,:);
    a = size(ddr);

        [pdf,~]=hist(ddr(:,2),hist_range);
        pdf = pdf/sum(pdf);
        cmap_temp  = pdf/max(pdf(:));
        pdf_concat = [pdf_concat,pdf'];
        cmap_concat = [cmap_concat,cmap_temp'];

%         title(['Range:' ,num2str(i)])
%         saveas(gcf,['../Matlab/Plots/',dataset,'Range:' ,num2str(i),'Fading Distribution.png'])
%         pause

end

figure('Visible','off')
s=surf(range_mesh,bin_mesh,pdf_concat,cmap_concat,'FaceAlpha',1);
% s=surf(range_mesh,bin_mesh,pdf_concat,'FaceAlpha',1);
ylim([-150,50]);
zlim([0,.3]);
s.EdgeColor='none';
colorbar;
title([title_name,' Process']);
saveas(gcf,['Plots/',file_name,'/',title_name,'.fig']);
saveas(gcf,['Plots/',file_name,'/',title_name,'.png']);
end

