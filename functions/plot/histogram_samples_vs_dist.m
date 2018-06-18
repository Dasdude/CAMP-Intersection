function [outputArg1,outputArg2] = histogram_samples_vs_dist(samples_linear,dist_obj,params,total_samples,per,title_string)
%PLOT_SAMPLES_VS_DIST Summary of this function goes here
%   Detailed explanation goes here
    
    expand_rate = int64((total_samples*(1-per))/length(samples_linear));
    expand_rate = max(expand_rate,1);
    if length(samples_linear)~=0
        total_samples = expand_rate*length(samples_linear)/(1-per);
    end
    samples_linear = repmat(samples_linear,expand_rate,1);
    model_dist = dist_obj.dist_handle(params);
    tr_val = icdf(model_dist,per);
    tr_val_dbm = linear2dbm(tr_val);
    gen_samples = model_dist.random(1,total_samples);
    gen_samples_trunc = gen_samples(gen_samples>tr_val);
    gen_samples_dbm = linear2dbm(gen_samples);
    gen_samples_dbm_trunc = gen_samples_dbm(gen_samples_dbm>tr_val_dbm);
    samples_dbm = linear2dbm(samples_linear);
    figure('Position',[1 1 800 600],'Visible','off');
    subplot(2,1,1)
    binEdges = [-150:70];
    hold on
    
    nak_hist = histogram(gen_samples_dbm,binEdges,'FaceColor','b');
    binEdges = nak_hist.BinEdges;
    histogram(gen_samples_dbm_trunc,binEdges,'FaceColor','g','FaceAlpha',.5);
    histogram(samples_dbm,binEdges,'FaceColor','r','FaceAlpha',.5);
    legend('Truncated wrt PER','Estimated','Field Samples','Location','northwest');
    
    subplot(2,1,2)
    hold on
    nak_hist =histogram(gen_samples,'FaceColor','b');
    binEdges = nak_hist.BinEdges;
    histogram(gen_samples_trunc,binEdges,'FaceColor','g','FaceAlpha',.5);
    histogram(samples_linear,binEdges,'FaceColor','r','FaceAlpha',.5);
    title('Linear Domain')
    legend('Truncated wrt PER','Estimated','Field Samples','Location','northeast');
    suptitle(sprintf('%s Estimated vs Field %s',title_string,dist_obj.params_string(params)));

end

