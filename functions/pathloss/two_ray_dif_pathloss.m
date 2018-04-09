function [params,alphas] = two_ray_dif_pathloss(pathloss_emp,Tx_height,Rx_height,lambda,carrier_freq,max_window_distance,same_fade_window,dist_lambda)
%2RAY_DIF_PATHLOSS Summary of this function goes here
%   Detailed explanation goes here
    max_distance = length(pathloss_emp);
    params = zeros(max_distance,3);
    w = max_window_distance;
    alpha=2.4;
    epsilon = 1.02;
    alphas = 0;
    tx_target = Tx_height;
    alpha_target=alpha;
    for i = 1:w:(max_distance-w)
        
        
%              loss_handle = @(x) pathloss_dif_loss(i,i+w,pathloss_emp,2,x,Tx_height,Rx_height,lambda,same_fade_window);
            loss_handle = @(x) pathloss_dif_loss_epsilon_find_std_based(i,i+w,pathloss_emp,alpha,x,Tx_height,Rx_height,lambda,same_fade_window);
            options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
            [epsilon_target,loss_val]=fmincon(loss_handle,[epsilon],[],[],[],[],1,5,[],options);
%             loss_handle = @(x) pathloss_dif_loss(i,i+w,pathloss_emp,2,x,Tx_height,Rx_height,lambda,same_fade_window);
%                 options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
%                 [epsilon_target,loss_val]=fmincon(loss_handle,[epsilon_target],[],[],[],[],1,5,[],options);
            fprintf('d1:%d,d2:%d  loss:%d eps:%d \n',i,i+w,loss_val,epsilon_target)
            alpha_target= alpha;
            for j = 1:40
%                 [alpha_target,alphas] = pathloss_dif_loss_find_alpha(i,i+w,pathloss_emp,epsilon_target,1,Tx_height,Rx_height,lambda,same_fade_window);
%                 fprintf('d1:%d,d2:%d  loss:%d alpha:%d  \n',i,i+w,loss_val,alpha_target)
%                 loss_handle = @(x) pathloss_dif_loss(i,i+w,pathloss_emp,x,epsilon_target,Tx_height,Rx_height,lambda,same_fade_window,dist_lambda);
%                 options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
%                 [alpha_target,loss_val]=fmincon(loss_handle,[alpha_target],[],[],[],[],0,5,[],options);
%                 fprintf('d1:%d,d2:%d  loss:%d epsilon:%d  \n',i,i+w,loss_val,epsilon_target)
                
%                 
%                 loss_handle = @(x) pathloss_dif_loss(i,i+w,pathloss_emp,alpha_target,x,Tx_height,Rx_height,lambda,same_fade_window,0);
%                 options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
%                 [epsilon_target,loss_val]=fmincon(loss_handle,[epsilon_target],[],[],[],[],1,inf,[],options);
%                 fprintf('d1:%d,d2:%d  loss:%d epsilon:%d  \n',i,i+w,loss_val,epsilon_target)
                
                    %% FOR STEVE COMMENTed
                [alpha_target,alphas] = pathloss_dif_loss_find_alpha(i,i+w,pathloss_emp,epsilon_target,tx_target,tx_target,lambda,same_fade_window);
                
                
%                 fprintf('d1:%d,d2:%d  loss:%d alpha:%d  \n',i,i+w,loss_val,alpha_target)
                
                
                 loss_handle = @(x) pathloss_dif_loss(i,i+w,pathloss_emp,alpha_target,x,tx_target,tx_target,lambda,same_fade_window,0);
                options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
                [epsilon_target,loss_val]=fmincon(loss_handle,[epsilon_target],[],[],[],[],1,inf,[],options);
%                 fprintf('d1:%d,d2:%d  loss:%d epsilon:%d  \n',i,i+w,loss_val,epsilon_target)
                
%                 loss_handle = @(x) pathloss_dif_loss(i,i+w,pathloss_emp,alpha_target,epsilon_target,x,x,lambda,same_fade_window,0);
%                 options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
%                 [tx_target,loss_val]=fmincon(loss_handle,[tx_target],[],[],[],[],1,inf,[],options);
%                 fprintf('d1:%d,d2:%d  loss:%d epsilon:%d  \n',i,i+w,loss_val,epsilon_target)
                
%                 loss_handle = @(x) pathloss_dif_loss(i,i+w,pathloss_emp,x(1),x(2),Tx_height,Rx_height,lambda,same_fade_window,dist_lambda);
%                 options = optimoptions(@fmincon,'Display','off','Algorithm','interior-point','MaxFunctionEvaluations',10000);
%                 [t_params,loss_val]=fmincon(loss_handle,[alpha_target,epsilon_target],[],[],[],[],[1,1],[inf,inf],[],options);
%                 
%                 epsilon_target = t_params(2);
%                 alpha_target = t_params(1);
%                 tx_height_target = t_params(3);
                fprintf('d1:%d,d2:%d  loss:%d epsilon:%d alpha:%d tx_height:%d \n',i,i+w,loss_val,epsilon_target,alpha_target,tx_target)
               
            end
            params(i:i+w-1,:) = repmat([alpha_target,epsilon_target,tx_target],[w,1]);
            break;
    end
    params(i+1:end,1) = alpha_target;
    params(i+1:end,2) = epsilon_target;
    params(i+1:end,3) = tx_target;
end

