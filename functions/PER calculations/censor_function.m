function [data_censored,per,packet_loss_stat] = censor_function(data,noise_level,pkt_size,truncation_value)
%CENSOR_FUNCTION Summary of this function goes here
%   Detailed explanation goes here
    switch nargin
        case 1
            noise_level = -98;
            pkt_size = 316;
        case 2
            pkt_size = 316;
    end
    switch pkt_size
        case 316
            a = 0.4997;
            b = 3.557;
            c = 1.292;
            d = 0.5;
        case -1
            data_censored = data(data>=truncation_value);
            per = 1- (length(data_censored)/length(data));
            packet_loss_stat = zeros(1,2);
            packet_loss_stat(1) = length(data)-length(data_censored);
            packet_loss_stat(2) = length(data);
            return
        otherwise
            a = 0.5;
            b = 3.346;
            c = 1.395;
            d = 0.5;
    end
    sinr = data - noise_level;
    keep_packet_rate = a * erf((sinr-b)/c) + d;
    keep_packet_rate(keep_packet_rate>1) = 1;
    keep_packet_rate(keep_packet_rate<0) = 0;
    select = rand(size(keep_packet_rate));
    select = select<keep_packet_rate;
    per = 1- (sum(select)./length(select));
    packet_loss_stat = zeros(1,2);
    packet_loss_stat(1) = length(select)-sum(select);
    packet_loss_stat(2) = length(select);
    data_censored = data(select);
end

