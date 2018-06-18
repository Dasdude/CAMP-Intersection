function [x,y] = plot_line_set(m,bias,x_lim,n)
% input is Nx2 bias : Nx1, 
figure;
x = linspace(x_lim(1),x_lim(2),n);
y = -(x.*m(:,1)+bias')./m(:,2);
plot(x,y);
grid on
hold on
ylim([min(y(:)),max(y(:))]);
plot(x_lim,[0,0],'black')
plot([0,0],[min(y(:)),max(y(:))],'black');
end