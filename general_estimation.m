clc
clearvars -except data_set
close all
clear
axis tight
'Correct Project'
experiment_name = 'SetFinal';
addpath(genpath('.'))
for run = 1:1
    mode_index = 2;
    clearvars -except mode_index experiment_name
    close all
    
    %% Constant Variables
    % Modes
    SAME_DENS_LOW = {'Same','Low','0','10',1.0043,2.0108};
    SAME_DENS_MED = {'Same','Medium','10','30',1.0091,2.0237};
    SAME_DENS_HIGH = {'Same','High','30','Inf',1.0036,2.0576};
    OP_DENS_LOW = {'Opposite','Low','0','10',1,2.1434};
    OP_DENS_MED = {'Opposite','Medium','10','25',1,2.1904};
    OP_DENS_HIGH = {'Opposite','High','25','Inf',1,2.26};
    mode_list = {SAME_DENS_LOW,SAME_DENS_MED,SAME_DENS_HIGH,OP_DENS_LOW,OP_DENS_HIGH};
    % Dataset variables
    d_min = 1;
    d_max = 800;
    xticks(0:10:d_max)
    % Model Variables
    FADING_BIN_SIZE = 1;
    TX_POWER = 17;
    CARRIER_FREQ=5.89*10^9;
    TX_HEIGHT = 1.4787;
    RX_HEIGHT = TX_HEIGHT;
    LIGHT_SPEED=3*10^8;
    TRUNCATION_VALUE= -94;
    lambda=LIGHT_SPEED/CARRIER_FREQ;
    %% input parameters
    show_gassuan_dist = 0;
    show_nakagami_dist = 0;
    calc_gaussian = 0;
    min_samples_per_cell = 100; % for estimating Fading
    use_mean_as_pathloss = 0;
    %% File Preperation
    mode = mode_list{mode_index};
    file_string = [mode{1},' Direction ',mode{2},' Density ',mode{3},' to ',mode{4},'.csv'];
    file_name_string = [experiment_name,'/',mode{1},' Direction ',mode{2},' Density ',mode{3},' to ',mode{4}];
    mkdir(['Plots/',file_name_string,'/Results'])
    mkdir(['Plots/',file_name_string]);
    %% Dataset prepare
    display('Data Prepare Phase')
    input  = file_string;
    csv_data = readtable(input,'ReadVariableNames',true);
    dataset_mat_dirty = [csv_data.Range,csv_data.RSS];
    any(isnan(dataset_mat_dirty))
    
    any(dataset_mat_dirty(:)<-100)
    dataset_cell_dirty = data_mat_cell(dataset_mat_dirty,d_max);
    packet_loss_stat = per_calc(dataset_cell_dirty,-95);
    per = packet_loss_stat(:,1)./packet_loss_stat(:,2);
%     packet_loss_stat(:,1)=packet_loss_stat(:,2)/2;
%     packet_loss_stat(:,1)=0;
    dataset_cell = truncate_data_cell(dataset_cell_dirty,TRUNCATION_VALUE-1);
    data_dbm_cell = dataset_cell;
    data_dbm_cell = data_dbm_cell(1:d_max);
    %% Pathloss Estimate
    display('Pathloss Estimation Phase')
%     EPSILON = mode{5};
%     ALPHA = mode{6};
    if calc_gaussian ==1 || exist(['Plots/',file_name_string,'/Results/','GmeanEst.mat'])==0
        data_dbm_mean = funoncellarray1input(data_dbm_cell,@mean);
        data_dbm_std = funoncellarray1input(data_dbm_cell,@std);
        data_mean_estimate_dbm = mean_estimator_gaussian_mle_adptv_bin_window(data_dbm_cell,[1,1],1,packet_loss_stat,-inf,0,1,file_name_string,show_gassuan_dist);
        figure;plot(1:d_max,data_mean_estimate_dbm(:,1),1:d_max,data_dbm_mean);legend('Gaussian Estimate Mean Data','Field Mean Data');saveas(gcf,['Plots/',file_name_string,'/','Gaussian Mean Compare.png']);
        figure;plot(1:d_max,data_mean_estimate_dbm(:,2),1:d_max,data_dbm_std);legend('Gaussian Estimate STD Data','Field STD Data');saveas(gcf,['Plots/',file_name_string,'/','Gaussian STD Compare.png']);
        data_mean_estimate_dbm = data_mean_estimate_dbm(:,1);
        save(['Plots/',file_name_string,'/Results/','GmeanEst.mat'],'data_mean_estimate_dbm')
    else
        if exist(['Plots/',file_name_string,'/Results/','nakmean.mat'])==2
            display('Nakmean Loaded')
            load(['Plots/',file_name_string,'/Results/','nakmean.mat'])
            data_mean_estimate_dbm = generated_rssi_dbm_mean;
            
        else
            load(['Plots/',file_name_string,'/Results/','GmeanEst.mat'])
            data_mean_estimate_dbm = data_mean_estimate_dbm(:,1);
        end
    end
%     [ALPHA,EPSILON,pathloss_expand_emp] = pathloss_estimator(data_dbm_cell,TX_HEIGHT,CARRIER_FREQ,per,-95,TX_POWER);
    data_mean_emperical = funoncellarray1input(data_dbm_cell,@mean);
    
    pathloss_emperical = TX_POWER - data_mean_emperical;
    pathloss_mean_estimate = TX_POWER - data_mean_estimate_dbm;
    [alpha,epsilon,tx_height] = pathloss_estimator_hossein_method(pathloss_mean_estimate,TX_HEIGHT,CARRIER_FREQ,packet_loss_stat,-95,TX_POWER,500,20,1);
    ALPHA = alpha(1);
    EPSILON = epsilon(1);
    TX_HEIGHT = tx_height(1);
    RX_HEIGHT = tx_height(1);
    pathloss = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,EPSILON,ALPHA,lambda,d_max);
    if use_mean_as_pathloss
        pathloss = pathloss_mean_estimate;
    end
    figure;plot(1:d_max,TX_POWER -  pathloss_emperical,'r',1:d_max,TX_POWER-pathloss,'b',1:d_max,data_mean_estimate_dbm,'g');title(['Pathloss:',' alpha :',num2str(ALPHA),' eps',num2str(EPSILON),'antenna height',num2str(TX_HEIGHT)]);legend('Field Median RSSI', '2 Ray', 'Estimated Mean');saveas(gcf,['Plots/',file_name_string,'/','Pathloss Compare.png']);    
%     pathloss = TX_POWER-data_mean_estimate_dbm(:,1);
    
%     pathloss = pathloss-pathloss;
    %% Fading Parameter Estimate
    display('Fading Estimation Phase')
    fading_dbm_cell = extract_fading(dataset_cell,pathloss,TX_POWER);
    fading_max_vals = funoncellarray1input(fading_dbm_cell,@max);
    fading_min_vals = funoncellarray1input(fading_dbm_cell,@min);
    fading_max_val = max(fading_max_vals);
    fading_min_val = min(fading_min_vals);
    fading_min_max = [fading_min_val-10,fading_min_val+10];
%     fading_dbm_celal = extract_fading(dataset_cell,TX_POWER-data_mean_estimate_dbm(:,1),TX_POWER);
    fading_linear_cell = dbm2linear(fading_dbm_cell);
%     [fading_params,fading_bin_start_edges,aprx_per,loss_vals] = fading_estimator_nakagami_mle_adptv_bin_bias(fading_linear_cell,[1,1,0],FADING_BIN_SIZE,d_min,packet_loss_stat,TRUNCATION_VALUE,1000,packet_loss_stat(:,2));
%     [fading_params,fading_bin_start_edges,aprx_per,loss_vals] = fading_estimator_nakagami_mle_adptv_bin_window(fading_linear_cell,[1,1,0],d_min,packet_loss_stat,TRUNCATION_VALUE,5000,30,file_name_string,show_nakagami_dist,fading_min_max);
    [fading_params,fading_bin_start_edges,aprx_per,loss_vals] = fading_estimator_nakagami_set(fading_linear_cell,[1,1,0],d_min,packet_loss_stat,TRUNCATION_VALUE,5000,800,file_name_string,show_nakagami_dist,min_samples_per_cell);
    %% Storing New Mean Estimate
    
    generated_fading_linear = nakagami_generator(fading_params,1e3);
    generated_fading_dbm = linear2dbm(generated_fading_linear);
    generated_rssi_dbm = add_fading(pathloss,generated_fading_dbm,TX_POWER);
    generated_rssi_dbm_truncated = truncate_data_cell(generated_rssi_dbm,TRUNCATION_VALUE);
    generated_rssi_dbm_mean = funoncellarray1input(generated_rssi_dbm,@mean);
    
    save(['Plots/',file_name_string,'/Results/','nakmean.mat'],'generated_rssi_dbm_mean')
    %% Saving Parameters
    display('Saving Parameters')
    
    nakagami_mu = fading_params(:,1);
    nakagami_omega = fading_params(:,2);
    tworay_pathloss_alpha = ALPHA;
    tworay_pathloss_epsilon = EPSILON;
    save(['Plots/',file_name_string,'/Results/','Parameters.mat'],'TX_HEIGHT','RX_HEIGHT','tworay_pathloss_alpha','tworay_pathloss_epsilon','TX_POWER','CARRIER_FREQ','nakagami_mu','nakagami_omega','EPSILON','ALPHA','fading_params','aprx_per','loss_vals','fading_bin_start_edges','pathloss','use_mean_as_pathloss')
    
    %% Percentile
    percentiles_generated = percentile_array([10,25,50,75,90],generated_rssi_dbm);
    percentiles_generated_trunc = percentile_array([10,25,50,75,90],generated_rssi_dbm_truncated);
    percentiles_rssi = percentile_array([10,25,50,75,90],data_dbm_cell);
    figure;plot(percentiles_generated(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI 10.png']);
    figure;plot(percentiles_generated_trunc(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI Truncated 10.png']);
    

end
    