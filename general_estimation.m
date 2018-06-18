clc
clearvars -except data_set
close all
clear
axis tight
'Correct Project'
experiment_name = 'AUG13';
addpath(genpath('.'))
%% Distribution
dist_obj_nak = distribution_type_class(@(x)makedist('nakagami',x(1),x(2)),'nakagami',{'mu','omega'},[0.5,0],[inf,inf]);
dist_obj_logn = distribution_type_class(@(x)makedist('lognormal',x(1),x(2)),'lognormal',{'mu','sigma'},[-inf,0],[3,3]);
dist_obj_wei = distribution_type_class(@(x)makedist('weibull',x(1),x(2)),'weibull',{'A','B'},[0,0],[5,5]);
dist_obj_ri = distribution_type_class(@(x)makedist('rician',x(1),x(2)),'rician',{'s','sigma'},[0,0],[5,5]);
dist_obj_ray = distribution_type_class(@(x)makedist('rayleigh',x(1)),'rayleigh',{'B'},[0],[5]);
dist_obj_cell = {dist_obj_nak,dist_obj_logn,dist_obj_wei,dist_obj_ri,dist_obj_ray};
dist_obj = dist_obj_cell{5};
%% Constant Iniit
SAME_LEG = {'same_leg'};
DIF_LEG_LOS = {'dif_leg_los'};
DIF_LEG_NLOS = {'dif_leg_nlos'};
%% PARMETERS
SUDO_CENSOR_VAL = -110;
FADING_BIN_SIZE = 1;
TX_POWER = 14;
CARRIER_FREQ=5.89*10^9;
TX_HEIGHT = 1.4787;
RX_HEIGHT = TX_HEIGHT;
LIGHT_SPEED=3*10^8;
TRUNCATION_VALUE= -91;
lambda=LIGHT_SPEED/CARRIER_FREQ;
d_min = 1;
noise_level = -98;pkt_size=-1;
%% ESTIMATION PARAMETERS
show_gassuan_dist = 0;
show_nakagami_dist = 1;
calc_gaussian = 0;
fixed_pathloss=1;
min_samples_per_cell = 10; % for estimating Fading
samples_in_neighborhood=1000;
use_mean_as_pathloss = 1;
d_max_percentile = 99.99;
censor_function_handle = @(x)censor_function(x,noise_level,pkt_size,TRUNCATION_VALUE);
for mode_index = 3:3
    for dist_index = 3:3
        dist_obj = dist_obj_cell{dist_index};
        dist_obj.censor_function = censor_function_handle;
        close all
        mode_list = {SAME_LEG,DIF_LEG_LOS,DIF_LEG_NLOS};
        %% File Preperation
        mode = mode_list{mode_index};
        relative_experiment_folder_path = sprintf('%s/%s/%s/',experiment_name,mode{1},dist_obj.dist_name);
        mkdir(['Plots/',relative_experiment_folder_path]);
        %% Dataset prepare
        display('Data Prepare Phase')
        dataset_file_path  = sprintf('Dataset/Ehsan/%s.csv',mode{1});
        csv_data = readtable(dataset_file_path,'ReadVariableNames',true);
        
        
        dataset_mat_dirty = [csv_data.TxRxDistance,csv_data.RSS];
        dataset_mat_dirty(dataset_mat_dirty(:,2)>300,2) = SUDO_CENSOR_VAL;
        
        d_max = floor(prctile(csv_data.TxRxDistance(csv_data.RSS<300),d_max_percentile));
%         xticks(0:10:d_max)
        dataset_cell_dirty = data_mat_cell(dataset_mat_dirty,d_max);
        data_dirty_median = funoncellarray1input(dataset_cell_dirty,@median);
        % FIXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        warning('fix this later')
%         packet_loss_stat = per_calc(dataset_cell_dirty,TRUNCATION_VALUE-1);
        [dataset_cell,per,packet_loss_stat] = censor_data(dataset_cell_dirty,censor_function_handle);
        data_dbm_cell = dataset_cell(1:d_max);
        %% Pathloss Estimate
        display('Pathloss Estimation Phase')
        if fixed_pathloss == 0
            if calc_gaussian ==1
                data_dbm_mean = funoncellarray1input(data_dbm_cell,@mean);
                data_dbm_std = funoncellarray1input(data_dbm_cell,@std);
                data_mean_estimate_dbm = mean_estimator_gaussian_mle_adptv_bin_window(data_dbm_cell,[1,1],1,packet_loss_stat,-inf,0,1,relative_experiment_folder_path,show_gassuan_dist);
                figure;plot(1:d_max,data_mean_estimate_dbm(:,1),1:d_max,data_dbm_mean);legend('Gaussian Estimate Mean Data','Field Mean Data');saveas(gcf,['Plots/',relative_experiment_folder_path,'/','Gaussian Mean Compare.png']);
                figure;plot(1:d_max,data_mean_estimate_dbm(:,2),1:d_max,data_dbm_std);legend('Gaussian Estimate STD Data','Field STD Data');saveas(gcf,['Plots/',relative_experiment_folder_path,'/','Gaussian STD Compare.png']);
                data_mean_estimate_dbm = data_mean_estimate_dbm(:,1);
                mkdir(['Plots/',relative_experiment_folder_path,'/Results/']);
                save(['Plots/',relative_experiment_folder_path,'/Results/','GmeanEst.mat'],'data_mean_estimate_dbm')
            else
                if exist(['Plots/',relative_experiment_folder_path,'/Results/','nakmean.mat'])==2
                    display('Nakmean Loaded')
                    load(['Plots/',relative_experiment_folder_path,'/Results/','nakmean.mat'])
                    data_mean_estimate_dbm = generated_rssi_dbm_mean;
                else

                    load(['Plots/',relative_experiment_folder_path,'/Results/','GmeanEst.mat'])
                end
            end
        end
        data_mean_emperical_true = funoncellarray1input(data_dbm_cell,@mean);
        data_mean_estimate_dbm = data_mean_emperical_true;
        pathloss_estimate = TX_POWER - data_mean_estimate_dbm;
        [alpha,epsilon,tx_height] = pathloss_estimator_hossein_method(pathloss_estimate,TX_HEIGHT,CARRIER_FREQ,packet_loss_stat,-95,TX_POWER,100,20,1);
        ALPHA = alpha(1);
        EPSILON = epsilon(1);
        TX_HEIGHT = tx_height(1);
        RX_HEIGHT = tx_height(1);
        pathloss = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,EPSILON,ALPHA,lambda,d_max);
    %     pathloss = 1.3*(20*log10(1:d_max)+20*log10(CARRIER_FREQ)+20*log10(4*pi/LIGHT_SPEED));
        figure;plot(1:d_max,data_dirty_median,'r',1:d_max,TX_POWER-pathloss,'b',1:d_max,data_mean_estimate_dbm,'g');title(['Pathloss:',' alpha :',num2str(ALPHA),' eps',num2str(EPSILON),'antenna height',num2str(TX_HEIGHT)]);legend('Field Mean RSSI', '2 Ray', 'Estimated Mean');saveas(gcf,['Plots/',relative_experiment_folder_path,'/','Pathloss Compare.png']);
        %% Fading Parameter Estimate
        display('Fading Estimation Phase')
        fading_dbm_cell = extract_fading(dataset_cell,pathloss,TX_POWER);
        fading_max_vals = funoncellarray1input(fading_dbm_cell,@max);
        fading_min_vals = funoncellarray1input(fading_dbm_cell,@min);
        fading_max_val = max(fading_max_vals);
        fading_min_val = min(fading_min_vals);
        fading_min_max = [fading_min_val-10,fading_min_val+10];
        fading_linear_cell = dbm2linear(fading_dbm_cell);
    %     [fading_params,fading_bin_start_edges,aprx_per,loss_vals] = fading_estimator_nakagami_mle_adptv_bin_bias(fading_linear_cell,[1,1,0],FADING_BIN_SIZE,d_min,packet_loss_stat,TRUNCATION_VALUE,1000,packet_loss_stat(:,2));
    %     [fading_params,fading_bin_start_edges,aprx_per,loss_vals] = fading_estimator_nakagami_mle_adptv_bin_window(fading_linear_cell,[1,1,0],d_min,packet_loss_stat,TRUNCATION_VALUE,5000,30,relative_experiment_folder_path,show_nakagami_dist,fading_min_max);

        [fading_params,fading_bin_start_edges,aprx_per,loss_vals] = fading_estimator_general(fading_linear_cell,dist_obj,packet_loss_stat,samples_in_neighborhood,800,relative_experiment_folder_path,show_nakagami_dist,min_samples_per_cell);
        %% Storing New Mean Estimate
        generated_fading_linear = sample_generator(dist_obj,fading_params,1e3);
        generated_fading_dbm = linear2dbm(generated_fading_linear);
        generated_rssi_dbm = add_fading(pathloss,generated_fading_dbm,TX_POWER);
        [generated_rssi_dbm_truncated,generated_per,~] = censor_data(generated_rssi_dbm,censor_function_handle);
%         generated_rssi_dbm_truncated = truncate_data_cell(generated_rssi_dbm,TRUNCATION_VALUE);
        generated_rssi_dbm_mean = funoncellarray1input(generated_rssi_dbm,@mean);
        mkdir(['Plots/',relative_experiment_folder_path,'/Results/']);
        save(['Plots/',relative_experiment_folder_path,'/Results/','nakmean.mat'],'generated_rssi_dbm_mean');
        %% Saving Parameters
        display('Saving Parameters')
        mkdir(['Plots/',relative_experiment_folder_path,'/Results'])
%         nakagami_mu = fading_params(:,1);
%         nakagami_omega = fading_params(:,2);
        tworay_pathloss_alpha = ALPHA;
        tworay_pathloss_epsilon = EPSILON;
        save(['Plots/',relative_experiment_folder_path,'/Results/','Parameters.mat'],'TX_HEIGHT','RX_HEIGHT','tworay_pathloss_alpha','tworay_pathloss_epsilon','TX_POWER','CARRIER_FREQ','EPSILON','ALPHA','fading_params','aprx_per','loss_vals','fading_bin_start_edges','dist_obj')

        %% Percentile
%         percentiles_generated = percentile_array([10,25,50,75,90],generated_rssi_dbm);
%         percentiles_generated_trunc = percentile_array([10,25,50,75,90],generated_rssi_dbm_truncated);
%         percentiles_rssi = percentile_array([10,25,50,75,90],data_dbm_cell);
%         figure;plot(percentiles_generated(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',relative_experiment_folder_path,'/','Percentile RSSI 10.png']);
%         figure;plot(percentiles_generated_trunc(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',relative_experiment_folder_path,'/','Percentile RSSI Truncated 10.png']);
    end
end