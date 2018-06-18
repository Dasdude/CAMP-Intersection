function [fading_linear_cell] = sample_generator(dist_obj,params,samples_per_bin,samples_list)
%NAKAGAMI_GENERATOR Summary of this function goes here
%   Parameters : Rx2 : Range x [mu, omega]
    fading_linear_cell = cell(size(params,1),1);
    
    if samples_per_bin>0    
        for i = 1:size(params,1)
            parameter = params(i,:);
            if any(isnan(parameter))
                continue
            end
            dist_fun  = dist_obj.dist_handle(parameter);
            fading_linear_cell{i} = dist_fun.random(samples_per_bin,1);
        end
    else
        for i = 1:size(params,1)
            parameter = params(i,:);
            if any(isnan(parameter))
                continue
            end
            dist_fun  = dist_obj.dist_handle(parameter);
            fading_linear_cell{i} = dist_fun.random(samples_list(i),1);
        end
    end
end

