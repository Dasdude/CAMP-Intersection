clc
clearvars -except data_set
close all
clear
axis tight
'Correct Project'
experiment_name = 'AUG7';
addpath(genpath('.'))
for mode_index = 1:1
    clearvars -except mode_index experiment_name
    close all
    %% Constant Variables
    % Modes
    same_low_up = 15;
    same_med_up = 40;

    opposite_low_up = 15;
    opposite_med_up = 40;
    hov = 0;
    SAME_LEG = {'same_leg'};
    DIF_LEG_LOS = {'dif_leg_los'};
    DIF_LEG_NLOS = {'dif_leg_nlos'};
%     IX_SOUTH = {'NorthEast','SouthWest'};
%     IX_NORTH = {'InterX','North'};
%     MX_EAST = {'MidX','East'};
%     MX_SOUTH = {'MidX','South'};
    mode_list = {SAME_LEG,DIF_LEG_LOS,DIF_LEG_NLOS};
    % Dataset variables
    d_min = 1;
    d_max = 400;
    
    % Model Variables
    FADING_BIN_SIZE = 1;
    TX_POWER = 14;
    CARRIER_FREQ=5.89*10^9;
    TX_HEIGHT = 1.4787;
    RX_HEIGHT = TX_HEIGHT;
    LIGHT_SPEED=3*10^8;
    TRUNCATION_VALUE= -90;
    lambda=LIGHT_SPEED/CARRIER_FREQ;
    %% input parameters
    show_gassuan_dist = 0;
    show_nakagami_dist = 1;
    calc_gaussian = 0;
    fixed_pathloss=1;
    min_samples_per_cell = 10; % for estimating Fading
    samples_in_neighborhood=1000;
    use_mean_as_pathloss = 1;
    %% File Preperation
    mode = mode_list{mode_index};
    file_string = sprintf('Dataset/Ehsan/%s.csv',mode{1});
    file_name_string = sprintf('%s/%s',experiment_name,mode{1});
    mkdir(['Plots/',file_name_string]);
    %% Dataset prepare
    display('Data Prepare Phase')
    input  = file_string;
    csv_data = readtable(input,'ReadVariableNames',true);
    d_max = floor(prctile(csv_data.TxRxDistance,90));
    xticks(0:10:d_max)
%     csv_data = csv_data(strcmp(csv_data.LinkType,'NLOS_Perpendicular'),:);
    dataset_mat_dirty = [csv_data.TxRxDistance,csv_data.RSS];
%     dataset_mat_dirty = [csv_data.RxDistance2Center+csv_data.TxDistance2Center,csv_data.RSS];
    dataset_mat_dirty(dataset_mat_dirty(:,2)>300,2) = -110;
    
    
    any(isnan(dataset_mat_dirty))
    
    any(dataset_mat_dirty(:)<-100)
    dataset_cell_dirty = data_mat_cell(dataset_mat_dirty,d_max);
    data_dirty_median = funoncellarray1input(dataset_cell_dirty,@median);
    packet_loss_stat = per_calc(dataset_cell_dirty,TRUNCATION_VALUE-1);
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
    if fixed_pathloss == 0
    if calc_gaussian ==1
        data_dbm_mean = funoncellarray1input(data_dbm_cell,@mean);
        data_dbm_std = funoncellarray1input(data_dbm_cell,@std);
        data_mean_estimate_dbm = mean_estimator_gaussian_mle_adptv_bin_window(data_dbm_cell,[1,1],1,packet_loss_stat,-inf,0,1,file_name_string,show_gassuan_dist);
        figure;plot(1:d_max,data_mean_estimate_dbm(:,1),1:d_max,data_dbm_mean);legend('Gaussian Estimate Mean Data','Field Mean Data');saveas(gcf,['Plots/',file_name_string,'/','Gaussian Mean Compare.png']);
        figure;plot(1:d_max,data_mean_estimate_dbm(:,2),1:d_max,data_dbm_std);legend('Gaussian Estimate STD Data','Field STD Data');saveas(gcf,['Plots/',file_name_string,'/','Gaussian STD Compare.png']);
        data_mean_estimate_dbm = data_mean_estimate_dbm(:,1);
        mkdir(['Plots/',file_name_string,'/Results/']);
        save(['Plots/',file_name_string,'/Results/','GmeanEst.mat'],'data_mean_estimate_dbm')
    else
        if exist(['Plots/',file_name_string,'/Results/','nakmean.mat'])==2
            display('Nakmean Loaded')
            load(['Plots/',file_name_string,'/Results/','nakmean.mat'])
            data_mean_estimate_dbm = generated_rssi_dbm_mean;
        else
            
            load(['Plots/',file_name_string,'/Results/','GmeanEst.mat'])
        end
    end
    end
%     [ALPHA,EPSILON,pathloss_expand_emp] = pathloss_estimator(data_dbm_cell,TX_HEIGHT,CARRIER_FREQ,per,-95,TX_POWER);
    data_mean_emperical_true = funoncellarray1input(data_dbm_cell,@mean);
%     data_mean_emperical = data_mean_estimate_dbm;
    data_mean_estimate_dbm = data_mean_emperical_true;
    pathloss_estimate = TX_POWER - data_mean_estimate_dbm;
    
    [alpha,epsilon,tx_height] = pathloss_estimator_hossein_method(pathloss_estimate,TX_HEIGHT,CARRIER_FREQ,packet_loss_stat,-95,TX_POWER,100,20,1);
    ALPHA = alpha(1);
    EPSILON = epsilon(1);
%     ALPHA = 1.9022;
%     EPSILON = 1.0105;
    TX_HEIGHT = tx_height(1);
    RX_HEIGHT = tx_height(1);
    pathloss = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,EPSILON,ALPHA,lambda,d_max);
    pathloss = 1.3*(20*log10(1:d_max)+20*log10(CARRIER_FREQ)+20*log10(4*pi/LIGHT_SPEED));
    figure;plot(1:d_max,data_dirty_median,'r',1:d_max,TX_POWER-pathloss,'b',1:d_max,data_mean_estimate_dbm,'g');title(['Pathloss:',' alpha :',num2str(ALPHA),' eps',num2str(EPSILON),'antenna height',num2str(TX_HEIGHT)]);legend('Field Mean RSSI', '2 Ray', 'Estimated Mean');saveas(gcf,['Plots/',file_name_string,'/','Pathloss Compare.png']);    
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
    [fading_params,fading_bin_start_edges,aprx_per,loss_vals] = fading_estimator_nakagami_set(fading_linear_cell,[1,1,0],d_min,packet_loss_stat,TRUNCATION_VALUE,samples_in_neighborhood,800,file_name_string,show_nakagami_dist,min_samples_per_cell);
    %% Storing New Mean Estimate
    generated_fading_linear = nakagami_generator(fading_params,1e3);
    generated_fading_dbm = linear2dbm(generated_fading_linear);
    generated_rssi_dbm = add_fading(pathloss,generated_fading_dbm,TX_POWER);
    generated_rssi_dbm_truncated = truncate_data_cell(generated_rssi_dbm,TRUNCATION_VALUE);
    generated_rssi_dbm_mean = funoncellarray1input(generated_rssi_dbm,@mean);
    mkdir(['Plots/',file_name_string,'/Results/']);
    save(['Plots/',file_name_string,'/Results/','nakmean.mat'],'generated_rssi_dbm_mean');
    %% Saving Parameters
    display('Saving Parameters')
    mkdir(['Plots/',file_name_string,'/Results'])
    nakagami_mu = fading_params(:,1);
    nakagami_omega = fading_params(:,2);
    tworay_pathloss_alpha = ALPHA;
    tworay_pathloss_epsilon = EPSILON;
    save(['Plots/',file_name_string,'/Results/','Parameters.mat'],'TX_HEIGHT','RX_HEIGHT','tworay_pathloss_alpha','tworay_pathloss_epsilon','TX_POWER','CARRIER_FREQ','nakagami_mu','nakagami_omega','EPSILON','ALPHA','fading_params','aprx_per','loss_vals','fading_bin_start_edges')
    
    %% Percentile
    percentiles_generated = percentile_array([10,25,50,75,90],generated_rssi_dbm);
    percentiles_generated_trunc = percentile_array([10,25,50,75,90],generated_rssi_dbm_truncated);
    percentiles_rssi = percentile_array([10,25,50,75,90],data_dbm_cell);
    figure;plot(percentiles_generated(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI 10.png']);
    figure;plot(percentiles_generated_trunc(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI Truncated 10.png']);
    %     shift_values_dbm = linear2dbm_mat(fading_params(:,3));
    %% Fading Distribution Generation
%     fading_linear_generated_cell = nakagami_generator(fading_params,10000);
%     gaussian_generated_cell = gaussian_generator(data_mean_estimate_dbm,10000);
%     gaussian_generated_mat = data_cell2mat(gaussian_generated_cell);
%     gaussian_generated_trunc_cell = truncate_data_cell(gaussian_generated_cell,-94);
%     gaussian_generated_trunc_mat = data_cell2mat(gaussian_generated_trunc_cell);
%     fading_linear_generated_cell_total_samples_compatible = nakagami_generator(fading_params,-1,packet_loss_stat(:,2));
%     fading_dbm_generated_cell = linear2dbm(fading_linear_generated_cell);
%     fading_dbm_generated_cell_total_samples_compatible = linear2dbm(fading_linear_generated_cell_total_samples_compatible);
%     %% Add Fading
%     data_generated_dbm_cell = add_fading(pathloss,fading_dbm_generated_cell,TX_POWER);
%     data_generated_dbm_cell_total_samples_compatible = add_fading(pathloss,fading_dbm_generated_cell_total_samples_compatible,TX_POWER);
%     %% Convert Cells to mat
%     data_dbm_generated_mat = data_cell2mat(data_generated_dbm_cell);
%     data_dbm_generated_mat_total_samples = data_cell2mat(data_generated_dbm_cell_total_samples_compatible);
%     data_dbm_generated_cell_truncated = truncate_data_cell(data_generated_dbm_cell,-94);
%     fading_dbm_generated_cell_truncated = extract_fading(data_dbm_generated_cell_truncated,pathloss,TX_POWER);
%     data_dbm_generated_cell_truncated_total_samples = truncate_data_cell(data_generated_dbm_cell_total_samples_compatible,-94);
%     data_dbm_generated_mat_truncated = data_cell2mat(data_dbm_generated_cell_truncated);
%     data_dbm_generated_mat_truncated_total_samples = data_cell2mat(data_dbm_generated_cell_truncated_total_samples);
% %     data_dbm_generated_mat_truncated = data_dbm_generated_mat(data_dbm_generated_mat(:,2)>-94,:);
%     fading_dbm_generated_mat = data_cell2mat(fading_dbm_generated_cell);
%     fading_dbm_generated_mat_total_samples = data_cell2mat(fading_dbm_generated_cell_total_samples_compatible);
%     fading_linear_mat = data_cell2mat(fading_linear_cell);
%     fading_linear_generated_mat = data_cell2mat(fading_linear_generated_cell_total_samples_compatible);
%     fading_linear_generated_mat_total_samples = data_cell2mat(fading_linear_generated_cell_total_samples_compatible)  ;
%     fading_dbm_mat = data_cell2mat(fading_dbm_cell);
%     data_dbm_mat = data_cell2mat(dataset_cell);
%     %% Calculate Pathloss Error
%     pathloss_error = linear2dbm(fading_params(:,3)');
%     pathloss_estimated_error_include =pathloss -pathloss_error;
% 
%     %% KLD
%     kld_fun_handle = @(x,y)kld_samples(x,y,64);
%     kld_fading_dbm = funoncellarray2input(fading_dbm_cell,fading_dbm_generated_cell,kld_fun_handle);
%     kld_fading_dbm_truncated = funoncellarray2input(fading_dbm_cell,fading_dbm_generated_cell_truncated,kld_fun_handle);
%     kld_rssi_dbm = funoncellarray2input(data_dbm_cell,data_generated_dbm_cell,kld_fun_handle);
%     kld_rssi_dbm_truncated = funoncellarray2input(data_dbm_cell,data_dbm_generated_cell_truncated,kld_fun_handle);
%     
%     ll_fun_handle = @(x)loglikelihood_samples(x{1},'lognakagami',x{2},x{3});
%     fading_trunc_val_dbm = -94+pathloss-TX_POWER;
%     tmp_input_cell_array = {fading_dbm_cell,fading_params,-inf*ones(length(fading_dbm_cell),1)};
%     ll_fading_dbm = funonarray(ll_fun_handle,tmp_input_cell_array);
%     tmp_input_cell_array = {fading_dbm_cell,fading_params,fading_trunc_val_dbm'};
%     ll_fading_dbm_truncated = funonarray(ll_fun_handle,tmp_input_cell_array);
%     
% %     kld_with_plot(fading_dbm_mat,fading_dbm_generated_mat,d_min,d_max,'Fading(dbm) KLD',file_name_string);
% %     kld_with_plot(fading_linear_mat,fading_linear_generated_mat,d_min,d_max,'Fading(AMP) KLD',file_name_string);
% %     kld_data_nak = kld_with_plot(data_dbm_mat,data_dbm_generated_mat,d_min,d_max,'RSSI KLD',file_name_string);
% %     kld_data_nak_trunc = kld_with_plot(data_dbm_mat,data_dbm_generated_mat_truncated,d_min,d_max,'RSSI KLD,Truncated Nakagami',file_name_string);
%     
%     %% Plot fading
% %     box_plot_2(fading_dbm_mat,fading_dbm_generated_mat,'GT','r','Nakagami','b',d_min,d_max,'Box Plot Fading(dbm)-Distance ',file_name_string,10,'on')
% %     box_plot_2(fading_linear_mat,fading_linear_generated_mat,'GT','r','Nakagami','b',d_min,d_max,'Box Plot Fading(amp)-Distance ',file_name_string,10,'on')
% %     box_plot_2(data_dbm_mat,data_dbm_generated_mat,'GT','r','Nakagami','b',d_min,d_max,'Box Plot RSSI-Distance ',file_name_string,10,'on')
% %     box_plot_2(data_dbm_generated_mat,data_dbm_mat,'Nakagami','b','GT','r',d_min,d_max,'Box Plot RSSI-Distance ',file_name_string,10,'on')
% %     box_plot_2(data_dbm_generated_mat_truncated,data_dbm_mat,'Nakagami Truncated','b','GT','r',d_min,d_max,'Box Plot RSSI-Distance ',file_name_string,10,'on')
% %     box_plot_2(gaussian_generated_mat,data_dbm_mat,'Gaussian','b','GT','r',d_min,d_max,'Box Plot RSSI-Distance ',file_name_string,10,'on')
% %     box_plot_2(gaussian_generated_trunc_mat,data_dbm_mat,'Gaussian-Truncated','b','GT','r',d_min,d_max,'Box Plot RSSI-Distance ',file_name_string,10,'on')
%     %% For samples Compatible
% %     box_plot_2(fading_dbm_mat,fading_dbm_generated_mat_total_samples,'GT','r','Nakagami','b',d_min,d_max,'Box Plot Fading(dbm)-Distance(same sample size)',file_name_string,10,'on')
% %     box_plot_2(fading_linear_mat,fading_linear_generated_mat_total_samples,'GT','r','Nakagami','b',d_min,d_max,'Box Plot Fading(amp)-Distance(same sample size)',file_name_string,10,'on')
% %     box_plot_2(data_dbm_mat,data_dbm_generated_mat_total_samples,'GT','r','Nakagami','b',d_min,d_max,'Box Plot RSSI-Distance(same sample size)',file_name_string,10,'on')
% %     box_plot_2(data_dbm_generated_mat_total_samples,data_dbm_mat,'Nakagami','b','GT','r',d_min,d_max,'Box Plot RSSI-Distance(same sample size)',file_name_string,10,'on')
% %     box_plot_2(data_dbm_generated_mat_truncated_total_samples,data_dbm_mat,'Nakagami Truncated','b','GT','r',d_min,d_max,'Box Plot RSSI-Distance(same sample size)',file_name_string,10,'on')
%     
%     %% Plot PER
%     
%     figure;plot(packet_loss_stat(:,2));hold;plot(packet_loss_stat(:,2)-packet_loss_stat(:,1));title('Total Samples vs Received Samples');legend('Total Samples','Recieved Samples');saveas(gcf,['Plots/',file_name_string,'/','Samples Received vs Total.png']);
    figure;plot(aprx_per);hold on;plot(packet_loss_stat(:,1)./packet_loss_stat(:,2));title('PER vs Smooth PER');legend('Approximated PER','PER');saveas(gcf,['Plots/',file_name_string,'/','PER.png']);
%     figure;plot(loss_vals);title('loss');saveas(gcf,['Plots/',file_name_string,'/','Loss.png']);
% %     figure;plot(loss_vals);title('loss');saveas(gcf,['Plots/',file_name_string,'/','Loss.png']);
%     figure;plot(kld_rssi_dbm-kld_rssi_dbm_truncated);title('kld RSSI - RSSI Truncated');saveas(gcf,['Plots/',file_name_string,'/','kld_diff.png']);
%     figure;plot(fading_params(:,1));title('Mu - Distance');saveas(gcf,['Plots/',file_name_string,'/','mu_distance.png']);
%     figure;plot(fading_params(:,2));title('Omega - Distance');saveas(gcf,['Plots/',file_name_string,'/','Omega_distance.png']);
%     generated_total_samples = funoncellarray1input(data_generated_dbm_cell,@length);
%     generated_recieved_samples = funoncellarray1input(data_dbm_generated_cell_truncated,@length);
%     per_generated = 1-(generated_recieved_samples./generated_total_samples);
%     figure; plot(per_generated);hold on; plot(aprx_per);plot(packet_loss_stat(:,1)./packet_loss_stat(:,2));title('PER Value');legend('Generated Data','Smooth Field','Field');saveas(gcf,['Plots/',file_name_string,'/','PER Comparison.png']);
% %     figure;plot(1:d_max,pathloss_emperical,'r',1:d_max,TX_POWER-pathloss,'b',1:d_max,data_mean_estimate_dbm(:,1),'g');title(['Pathloss:',' alpha :',num2str(ALPHA),' eps',num2str(EPSILON)]);legend('Field Median RSSI', '2 Ray', 'Estimated Mean');saveas(gcf,['Plots/',file_name_string,'/','Pathloss Compare.png']);
% %     figure('Position',[1 1 1920 1080],'Visible','off');plot(pathloss);title('Pathloss(2Ray) - Distance');saveas(gcf,['Plots/',file_name_string,'/','Pathloss.png']);
% %     figure('Position',[1 1 1920 1080],'Visible','off');plot(pathloss_estimated_error_include);title('Pathloss(2Ray+Est Error) - Distance');saveas(gcf,['Plots/',file_name_string,'/','PathlosswithEstError.png']);
% %     figure('Position',[1 1 1920 1080],'Visible','off');plot(pathloss_error);title('Pathloss Estimated Error - Distance');saveas(gcf,['Plots/',file_name_string,'/','PathlossError.png']);
%     %% KLD Plot
%     
%     figure;plot(ll_fading_dbm);
%     hold on ;plot(ll_fading_dbm_truncated);title('Log Likelihood RSSI - Distance');legend('Full Distribution','Truncated Distribution');saveas(gcf,['Plots/',file_name_string,'/','LL RSSI.png']);
%     figure;plot(kld_rssi_dbm);
%     hold;plot(kld_rssi_dbm_truncated);title('KLD RSSI - Distance');legend('Full Distribution','Truncated Distribution');saveas(gcf,['Plots/',file_name_string,'/','KLD RSSI.png']);
%     figure;plot(kld_fading_dbm);
%     hold;plot(kld_fading_dbm_truncated);title('KLD Fading - Distance');legend('Full Distribution','Truncated Distribution');saveas(gcf,['Plots/',file_name_string,'/','KLD Fading.png']);
%     %% Percentile Plot
%     percentiles_generated = percentile_array([10,25,50,75,90],data_generated_dbm_cell);
%     percentiles_generated_trunc = percentile_array([10,25,50,75,90],data_dbm_generated_cell_truncated);
%     percentiles_rssi = percentile_array([10,25,50,75,90],data_dbm_cell);
%     figure;plot(percentiles_generated(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI.png']);
%     figure;plot(percentiles_generated_trunc(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI Truncated.png']);
%     figure;plot(percentiles_generated(:,[2,3,4]));hold on ;plot(percentiles_rssi(:,[2,3,4]));legend('25% model','50% model','75% model','25% field','50% field','75% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI.png']);
%     figure;plot(percentiles_generated_trunc(:,[2,3,4]));hold on ;plot(percentiles_rssi(:,[2,3,4]));legend('25% model','50% model','75% model','25% field','50% field','75% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI Truncated.png']);
%     %% PER PLOT
%    
%     %% Pathloss Plot
% %     plot(1:d_max,pathloss_emperical,'r',1:d_max,TX_POWER-pathloss,'b');title('Pathloss(Median RSSI)(red) vs Estimated Pathloss(blue)');saveas(gcf,['Plots/',file_name_string,'/','KLDrssiTruncateddbm.png']);
%     mkdir(['Plots/',file_name_string,'/Results'])
%     nakagami_mu = fading_params(:,1);
%     nakagami_omega = fading_params(:,2);
%     tworay_pathloss_alpha = ALPHA;
%     tworay_pathloss_epsilon = EPSILON;
%     save(['Plots/',file_name_string,'/Results/','Parameters.mat'],'TX_HEIGHT','RX_HEIGHT','tworay_pathloss_alpha','tworay_pathloss_epsilon','TX_POWER','CARRIER_FREQ','nakagami_mu','nakagami_omega')
% %     dlmwrite(['Plots/',file_name_string,'/Results/','Parameters.txt'],TX_HEIGHT,RX_HEIGHT,';')
%     close all
end
    