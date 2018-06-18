clc
close all
clear
total_samples = 10000;
%% Define Latent Variables Range
y1 = [1:5];
p1 = [.2,.8,.3,.8]
p1 = p1./sum(p1);
mu_y1 = [5,1,4,20]
sigma_y1 = [5,2,3,10];
treshold = 10;
[mixture_samples,per,mixture_samples_all] = create_mixture_normal(total_samples,mu_y1,sigma_y1,p1,treshold);
% mixture_samples_censored = mixture_samples_all(mixture_samples_all<treshold);
% mixture_samples = mixture_samples_all(mixture_samples_all>=treshold);
% per = length(mixture_samples_censored)./length(mixture_samples_all);
%% Mixture Decomposition
mixture_loss_fn =@(x)mixture_loss(mixture_samples',x(1,:),x(2,:),x(3,:),'normal',per); 
total_dist = 1;
p_init = ones(1,total_dist);
% p_init = ones(1,total_dist)./total_dist;
mu_init = (randn(1,total_dist)*std(mixture_samples))+mean(mixture_samples);
    sigma_init = ones(1,total_dist);
init_param = [p_init;mu_init;sigma_init];
loss_all = inf;
for total_dist = total_dist:total_dist+3    
    options = optimoptions('fminunc','Display','iter','Algorithm','quasi-newton');
    
    params = fminunc(mixture_loss_fn,init_param,options);
    loss = mixture_loss_fn(params)
    init_param = randn(3,total_dist+1);
    init_param(2:3,1:total_dist) = params(2:3,:)+rand('like',params(2:3,:));
    
    [~,idx] = min(params(1,:));
    init_param(2:3,end) =mean(params(2:3,:),2);
    init_param(1,:) = rand(1,total_dist+1);
    total_dist
end



% ylim([0,1000]);
% xlim([-10,10]);
mu = params(2,:);sigma = params(3,:);p= abs(params(1,:))./sum(abs(params(1,:)));
tr = find_tresh_with_per('normal',p,mu,sigma,per);

[recons_samples,per_const,recons_samples_all] = create_mixture_normal(total_samples,params(2,:),params(3,:),abs(params(1,:))./sum(abs(params(1,:))),tr);
% xlim_temp = xlim;
% ylim_temp = ylim;
% xlim(xlim_temp);
% ylim(ylim_temp);
% figure
figure;subplot(2,2,1);histogram(mixture_samples,'Normalization','probability');title(sprintf('GT Cut per:%d',per))
subplot(2,2,3);histogram(recons_samples,'Normalization','probability');title(sprintf('recons Cut per:%d',per_const))
subplot(2,2,2);histogram(mixture_samples_all,'Normalization','probability');title(sprintf('GT ALL per:%d',per))
subplot(2,2,4);histogram(recons_samples_all,'Normalization','probability');title(sprintf('recons ALL per:%d',per_const))

% ylim([0,1000]);
% mixture_loss(mixture_samples',params(1,:),params(2,:),params(3,:));
% mixture_loss(mixture_samples',p1,mu_y1,sigma_y1);