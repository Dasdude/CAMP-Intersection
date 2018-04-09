function [ll] = loglikelihood_samples(samples,dist_name,params,trunc_val)
%LOGLIKELIHOOD_SAMPLES Summary of this function goes here
%   Detailed explanation goes here
    if strcmpi(dist_name,'lognakagami')
        % samples should be in log domain, put trunc_val shows how
        % truncated the nakagami distribution should be
        min(samples);
        pd = makedist('nakagami','mu',params(1),'omega',params(2));
        samples_up = samples+.5;
        samples_down = samples-.5;
        trunc_val_linear = dbm2linear([trunc_val]);
        trunc_val_linear = trunc_val_linear(1);
        pg_rate  = 1- cdf(pd,trunc_val_linear);
        samples_up_linear =  dbm2linear(samples_up);
        samples_down_linear = dbm2linear(samples_down);
        cdf_up = cdf(pd,max(trunc_val_linear,samples_up_linear));
        cdf_down = cdf(pd,max(trunc_val_linear,samples_down_linear));
        pmf = (cdf_up-cdf_down)/pg_rate;
        
        ll = -mean(log2(pmf+eps));
        
        pd2 = makedist('nakagami','mu',params(1),'omega',params(2));
        samples_up2 = samples+.5;
        samples_down2 = samples-.5;
        trunc_val_linear2 = dbm2linear([-inf]);
        trunc_val_linear2 = trunc_val_linear2(1);
        pg_rate2  = 1- cdf(pd2,trunc_val_linear2);
        samples_up_linear2 =  dbm2linear(samples_up2);
        samples_down_linear2 = dbm2linear(samples_down2);
        cdf_up2 = cdf(pd,max(trunc_val_linear2-.5,samples_up_linear2));
        cdf_down2 = cdf(pd,max(trunc_val_linear2-.5,samples_down_linear2));
        pmf2 = (cdf_up2-cdf_down2)/pg_rate2;
        
        ll_non_trunc = -mean(log2(pmf2+eps));
    end
end

