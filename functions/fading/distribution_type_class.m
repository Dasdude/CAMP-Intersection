classdef distribution_type_class
    %DISTRIBUTION_CLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dist_handle;
        dist_name;
        dist_params_bounds_max;
        dist_params_bounds_min;
        dist_params_names;
        censor_function;
    end
    methods
        function obj = distribution_type_class(dist_handle,dist_name,params_names,params_min_bound,params_max_bound)
            %DISTRIBUTION_CLASS Construct an instance of this class
            %   Detailed explanation goes here
            obj.dist_handle = dist_handle;
            obj.dist_name = dist_name;
            obj.dist_params_names = params_names;
            obj.dist_params_bounds_max = params_max_bound;
            obj.dist_params_bounds_min = params_min_bound;
        end
        function samples = generate_samples(parameters,total_samples)
            
            dist_fun = obj.dist_handles(parameters);
            samples = dist_fun.random(total_samples,1);
        end
        function param_length = get_dof(obj)
            param_length = length(obj.dist_params_names);
        end
        function out_string = params_string(obj,params)
            out_string = '';
            for i = 1:obj.get_dof()
                out_string = [out_string,sprintf(' %s:%g,',obj.dist_params_names{i},params(i))];
            end
        end
        
    end
end

