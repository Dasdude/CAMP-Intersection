clc
close all
clear
TX_POWER = 20;
CARRIER_FREQ=5.89*10^9;
TX_HEIGHT = 1.4787;
RX_HEIGHT = TX_HEIGHT;
LIGHT_SPEED=3*10^8;
TRUNCATION_VALUE= -94;
lambda=LIGHT_SPEED/CARRIER_FREQ;
pathloss = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,1.1,2.4,lambda,300);

d1 = 10 , d2 = 30;
d1_2 = 50,d2_2 = 200;
dp_val = pathloss(d2)-pathloss(d1);
dp_val_2 = pathloss(d2_2)-pathloss(d1_2);
epsil_iter = 1:.01:2;
alpha_iter = 1:.1:2;
[alpha_mesh,epsil_mesh]=meshgrid(alpha_iter,epsil_iter);
loss = zeros(size(alpha_mesh));
for i = 1:length(alpha_mesh(:))
        pl_estimate = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,epsil_mesh(i),alpha_mesh(i),lambda,300);
        pl_estimate_2 = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,epsil_mesh(i),alpha_mesh(i),lambda,300);
        loss(i) = abs(dp_val - (pl_estimate(d2)-pl_estimate(d1))).^2+abs(dp_val_2 - (pl_estimate_2(d2_2)-pl_estimate_2(d1_2))).^2;
        
end
figure;
hold on
for eps = 1:.1:2
    pathloss  = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,eps,2.1,lambda,300);
    plot(pathloss);
end
surf(alpha_mesh,epsil_mesh,loss)