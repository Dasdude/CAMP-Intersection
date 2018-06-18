clc
close all


rss = -100:.01:-80;
a = 0.5;
b = 3.346;
c = 1.395;
d = 0.5;
sinr = rss+98;
result = a*erf((sinr-b)/c)+d;
result(result>1) = 1;
result(result<0) =0;

plot(rss,result);
grid on;

rss = -100:.01:-80;
a = 0.4997;
		b = 3.557;
		c = 1.292;
		d = 0.5;
sinr = rss+98;
result = a*erf((sinr-b)/c)+d;
result(result>1) = 1;
result(result<0) =0;
hold on
plot(rss,result);
grid on;