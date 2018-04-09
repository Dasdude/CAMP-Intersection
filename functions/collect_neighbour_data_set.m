function [res,start_point,end_point,samples_ratio] = collect_neighbour_data_set(data_cell,mid_point,min_samples,max_dist,min_samples_per_cell)
%COLLECT_NEIGHBOUR_DATA Summary of this function goes here
%   Detailed explanation goes here
    d_max = length(data_cell);
    s = mid_point; % start 
    e = mid_point;  % end
    samples =length(data_cell{e}) ;
    cell_agg = {data_cell{e}};
    cell_agg_idx = 1;
    k=1;
    samples_ratio = zeros([1,d_max])*nan;
    samples_ratio(mid_point)=1;
    while samples<min_samples && (e-s<=max_dist)
        
        k = 1-k;
        s2=s;
        e2=e;
        s = max([s-(1-k),1]);
        e = min([e+k,d_max]);
        cell_pick_index = (s2-s)*s + (e-e2)*e;
        
        if abs(d_max-e)+abs(s-1)==0
            break;
            
        end
        if cell_pick_index~=0
            cell_agg_idx = cell_agg_idx+1;
            if length(data_cell{cell_pick_index})<min_samples_per_cell
                continue
            end
            samples_to_pick = min(length(data_cell{cell_pick_index}),min_samples-samples);
            idx = randperm(length(data_cell{cell_pick_index}));
            idx = idx(1:samples_to_pick);
            temp_data = data_cell{cell_pick_index};
            samples_ratio(cell_pick_index) = samples_to_pick/(length(temp_data)+eps);
            cell_agg{cell_agg_idx}=temp_data(idx);
            samples = samples+samples_to_pick;
            
        end
%         samples = samples+(s2-s)*length(data_cell{s})+(e-e2)*length(data_cell{e});
        
    end
    res = concat_cell(data_cell,s,e);
    start_point = s;
    end_point = e;
end

