function [outputArg1,outputArg2] = histogram_samples_vs_dist(samples,dist_name,params,total_samples,per,pre_title)
%PLOT_SAMPLES_VS_DIST Summary of this function goes here
%   Detailed explanation goes here
    figure('Position',[1 1 800 600],'Visible','off');
    expand_rate = int64((total_samples*(1-per))/length(samples));
    expand_rate = max(expand_rate,1);
    if length(samples)~=0
        total_samples = expand_rate*length(samples)/(1-per);
    end
    samples = repmat(samples,expand_rate,1);
    if strcmpi(dist_name,'lognakagami')
        samples_nak = nakagami_generator([params(1),params(2),1],total_samples);
        samples_nak = samples_nak{1};
        samples_nak_log = linear2dbm(samples_nak);
        
        
        pd = makedist('nakagami','mu',params(1),'omega',params(2));
        tr_val = icdf(pd,per);
        s_nak_tr = samples_nak(samples_nak>tr_val);
        s_nak_tr_log = linear2dbm(s_nak_tr);
        samples_log = linear2dbm(samples);
        binEdges = [-150:70];
        nak_hist = histogram(samples_nak_log,binEdges,'FaceColor','b');
%         binEdges = nak_hist.BinEdges;
        
        hold on
        

        s_nak_tr_hist  = histogram(s_nak_tr_log,binEdges,'FaceColor','g','FaceAlpha',.5);
        est_nak_hist = histogram(samples_log,binEdges,'FaceColor','r','FaceAlpha',.5);

        box off
        axis tight
        legend('Truncated Nakagami','Estimated Nakagami','Field Samples')
        title([pre_title,' Log Nakagami PER: ',num2str(per),' Alpha: ',num2str(params(1)),' Omega: ',num2str(params(2))])
    end
    if strcmpi(dist_name,'nakagami')
        samples_nak = nakagami_generator([params(1),params(2),1],total_samples);
        samples_nak = samples_nak{1};
        pd = makedist('nakagami','mu',params(1),'omega',params(2));
        tr_val = icdf(pd,per);
        s_nak_tr = samples_nak(samples_nak>tr_val);
        nak_hist = histogram(samples_nak,'FaceColor','b');
        binEdges = nak_hist.BinEdges;
        hold on


        s_nak_tr_hist  = histogram(s_nak_tr,binEdges,'FaceColor','g','FaceAlpha',.5);
        est_nak_hist = histogram(samples,binEdges,'FaceColor','r','FaceAlpha',.5);

        box off
        axis tight
        legend('Estimated Nakagami','Field Samples','Truncated Nakagami')
        title([pre_title,' Nakagami PER:',num2str(per),' Alpha: ',num2str(params(1)),' Omega: ',num2str(params(2))])
    end
    if strcmpi(dist_name,'normal')


        samples_nak = gaussian_generator([params(1),params(2),1],total_samples);
        samples_nak = samples_nak{1};
        pd = makedist('normal','mu',params(1),'sigma',params(2));
        tr_val = icdf(pd,per);
        s_nak_tr = samples_nak(samples_nak>tr_val);
        samples_hist = histogram(samples,'FaceColor','r');
        binEdges = samples_hist.BinEdges;
        
        nak_hist = histogram(samples_nak,'FaceColor','b','FaceAlpha',.5);
        binEdges = [-110,binEdges,nak_hist.BinEdges,-10];
        binEdges = sort(binEdges);
        binEdges = -140:1:-10;
        samples_hist = histogram(samples,binEdges,'FaceColor','r');
        hold on
        nak_hist = histogram(samples_nak,binEdges,'FaceColor','b','FaceAlpha',.5);
        s_nak_tr_hist  = histogram(s_nak_tr,binEdges,'FaceColor','g','FaceAlpha',.5);
        

        box off
        axis tight
        legend('Field Samples','Estimated Gaussian','Truncated Gaussian')
        title([pre_title,' Gaussian Estimating Distribution with PER:',num2str(per)])
    end
    hold off
    
end

