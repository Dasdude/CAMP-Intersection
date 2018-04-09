function [outputArg1,outputArg2] = generate_fading_syntetic(d_max)
%GENERATE_FADING_SYNTETIC Summary of this function goes here
%   Detailed explanation goes here
x = linspace(0,1,d_max);
mu = (exp(x)./(exp(x)+1))*10 -4.4
omega = randi(10,1,d_max);
x = linspace(0,10,d_max);
per_rate=(exp(x)./(exp(x)+1))-.49;
mean = ;
data_non_biased = random('nakagami',mu,omega,1000000,1);
data = data_non_biased+mean;
end

