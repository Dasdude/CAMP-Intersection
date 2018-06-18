clear
addpath(genpath('.'))
[a,b] = get_line_from2points([1,0;0,0;-1,1],[0,1;1,1;1,-1]);
% [x,y]=plot_line_set(a,b,[-2,2],3)
projectpoint_on_lines(a,b,[1,0;-1,1])