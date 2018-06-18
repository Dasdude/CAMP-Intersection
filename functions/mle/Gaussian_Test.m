close all
clear
mu = 1
omega = 2
per_rate=.8

range = 0:.1:15
%% Sample Nakagami
data = random('Normal',mu,omega,1000000,1);
hist(data,0:.01:5);
pdf_nak_estimated = makedist('Normal','mu',mu,'sigma',omega);
est_pdf_trunc_val = icdf(pdf_nak_estimated,per_rate);
%% Truncate
data_trunc = data(data>est_pdf_trunc_val);
figure;
hist(data_trunc,0:.01:5);
%% apply mle
per = 1-(length(data_trunc)/length(data));
% [params,val]=mle_nakagami_truncated([2,.2],data_trunc,per,.8)
% [params,val]=mle_nakagami_truncated([5,.1],data_trunc,per,.8)
% 
% [params_1,val_1]=mle_nakagami_truncated([4,4],data_trunc,per,est_pdf_trunc_val);
% [params_2,val_2]=mle_nakagami_truncated([1,1],data_trunc,per,est_pdf_trunc_val);
% % loglikelihood_nakagami([alpha,omega],data_trunc,per,.8)
% data_1 = random('nakagami',params_1(1),params_1(2),1000000,1);
% % data = data./sum(data(:))
% figure;
% pdf1 = histc(data_1,range);
% pdf1 = pdf1./sum(pdf1);
% 
% data_2 = random('nakagami',params_2(1),params_2(2),1000000,1);
% % data = data./sum(data(:))
% 
% pdf2 = histc(data_2,range);
% pdf2 = pdf2./sum(pdf2);
% pdf3 = histc(data,range);
% pdf3 = pdf3./sum(pdf3);
% plot(range,pdf2,'r',range,pdf1,'b',range,pdf3,'g')
% params_1
% val_1
% params_2
% val_2
mu_iter = -2:.1:4;
omega_iter=0:.1:4;
val = zeros(size(omega_iter,2),size(mu_iter,2));
for mu_idx = 1:size(mu_iter,2)
    mu_idx
    for omega_idx=1:size(omega_iter,2)
        
%         omega_idx
        val(omega_idx,mu_idx)=kld_gaussian([mu_iter(mu_idx),omega_iter(omega_idx)],data_trunc,per_rate,est_pdf_trunc_val);
    end
end
c =val;
c= -log(abs(c));

surf(mu_iter,omega_iter,val,c)
xlabel('MU')
ylabel('omega')
zlabel('kld_truncated')
zlim([0,10])
title(['Loss function PER:',num2str(per_rate),'\mu:',num2str(mu),' \omega:',num2str(omega)])
% saveas(gcf,['Plots/MLE/','Loss function PER:',num2str(per_rate),'mu:',num2str(mu),' omega:',num2str(omega),'.fig']);
% saveas(gcf,['Plots/MLE/','Loss function PER:',num2str(per_rate),'mu:',num2str(mu),' omega:',num2str(omega),'.png']);