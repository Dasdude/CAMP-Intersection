clc
close all
clear
d = [eps:10];
tr = 1;
per = .20;

mu = .5:.005:10
omega = eps:.005:10
[mu_mesh,omega_mesh] = meshgrid(mu,omega)
error = zeros(size(mu,2),size(omega,2))*nan; 
for i= 1:length(mu)
    for j = 1:length(omega)
        pdf_i = makedist('Nakagami',mu(i),omega(j));
        tr_i = icdf(pdf_i,per);
        error(i,j) = abs(tr_i - tr);
        
%         if tr_i 
    end
end

mu_candid = mu_mesh(error<.001)
omega_candid = omega_mesh(error<.001)
error(error<.01)
