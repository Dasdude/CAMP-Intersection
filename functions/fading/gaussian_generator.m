function [fading_linear_cell] = gaussian_generator(params,samples_per_bin,samples_list)
%NAKAGAMI_GENERATOR Summary of this function goes here
%   Parameters : Rx2 : Range x [mu, omega]
    fading_linear_cell = cell(size(params,1),1);
    if samples_per_bin>0    
        for i = 1:size(params,1)
            parameter = params(i,:);
            if any(isnan(parameter))
                continue
            end
            fading_linear_cell{i} = random('normal',parameter(1),parameter(2),samples_per_bin,1);
%             fading_linear_cell{i} = fading_linear_cell{i}.*params(i,3);
        end
    else
        for i = 1:size(params,1)
            parameter = params(i,:);
            if any(isnan(parameter))
                continue
            end
            fading_linear_cell{i} = random('normal',parameter(1),parameter(2),samples_list(i),1);
%             fading_linear_cell{i} = fading_linear_cell{i}.*params(i,3);
        end
    end
end

