function [m,b] = get_line_from2points(x1,x2)
%GET_LINE_FROM2POINTS Summary of this function goes here
%   x1 = Nx2 x2= Nx2  m = Nx2 b = Nx1
m = x2-x1;
m = [m(:,2),-m(:,1)];
b = sum(-m'.*x1');
b = b';
end

