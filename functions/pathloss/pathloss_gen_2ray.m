function [path_loss] = pathloss_gen_2ray(Tx_height,Rx_height,epsilon,alpha,lambda,d_max)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    distance = 1:d_max;
    distance_los = sqrt(distance.^2+(Tx_height-Rx_height)^2);
    distance_ref = sqrt(distance.^2+(Tx_height+Rx_height)^2);

    sint = (Tx_height+Rx_height)./distance_ref;
    cost = distance./distance_ref;

    Gamma = (sint-sqrt(epsilon-cost.^2))./(sint+sqrt(epsilon-cost.^2));
    Phi = 2*pi*(distance_los-distance_ref)/lambda;

    temp = 1+(Gamma .* exp(1i*Phi));
    path_loss = 10*alpha*log10((4*pi)*(distance/lambda).*(abs(temp).^(-1)));
end

