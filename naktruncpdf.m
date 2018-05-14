function [pdf] = naktruncpdf(x,m,o,per)
%NAKTRUNCPDF Summary of this function goes here
%   Detailed explanation goes here
b = truncate(makedist('Nakagami',m,o),icdf(makedist('Nakagami',m,o),per),inf);
pdf = b.pdf(x)+eps;
end

