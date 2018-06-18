function [ proj] = projectpoint_on_lines( m,b,x )
%PROJECTPOINT_ON_LINES proj = NxM m  = Mx2 b = Mx1 x = Nx2 
%   Detailed explanation goes here
N = size(x,1);
proj = x*m'+repmat(b',N,1);

end

