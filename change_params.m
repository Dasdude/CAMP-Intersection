clc
close all
clear
addpath(genpath('.'))
%% File Names
mode_index =6;
same_low_up = 15;
same_med_up = 30;

opposite_low_up = 15;
opposite_med_up = 30;

SAME_DENS_LOW = {'same','low','0',same_low_up,1.0043,2.0108};
SAME_DENS_MED = {'same','med',same_low_up,same_med_up,1.0091,2.0237};
SAME_DENS_HIGH = {'same','high',same_med_up,100,1.0036,2.0576};
OP_DENS_LOW = {'opposite','low','0',opposite_low_up,1,2.1434};
OP_DENS_MED = {'opposite','med',opposite_low_up,opposite_med_up,1,2.1904};
OP_DENS_HIGH = {'opposite','high',opposite_med_up,100,1,2.26};
mode_list = {SAME_DENS_LOW,SAME_DENS_MED,SAME_DENS_HIGH,OP_DENS_LOW,OP_DENS_MED,OP_DENS_HIGH};
mode = mode_list{mode_index};
experiment_name = 'April18 OpHigh';
minimal_experiment_name = [mode{1},' Dir ',mode{2},' Density '];
mode_name = [mode{1},' Direction ',mode{2},' Density ',num2str(mode{3}),' to ',num2str(mode{4})];
parameter_folder = ['Plots/',experiment_name,'/',mode_name,'/Results'];
parameter_path = [parameter_folder,'/Parameters.mat'];
%% Load Params
load(parameter_path);
%% Change Parameters
    param_index = 450;
    fading_params(param_index:end,2) = fading_params(param_index,2);
    fading_params(param_index:end,1) = fading_params(param_index,1);
%     fading_params(131:132,2) = fading_params(130,2);
%     fading_params(131:132,1) = fading_params(130,1);
    
%    %Fourier 
%    omega_freq = fft(fading_params(:,2));
%    omega_freq(750:end) = 0;
%    fading_params(:,2) = abs(ifft(omega_freq));
%    mu_freq = fft(fading_params(:,1));
%    mu_freq(750:end) = 0;
%    fading_params(:,1) = abs(ifft(mu_freq));
%    %Truncate
%    fading_params(700:end,2) = fading_params(600,2);
%     fading_params(700:end,1) = fading_params(600,1);
    nakagami_mu = fading_params(:,1);
    nakagami_omega = fading_params(:,2);
   save([parameter_folder,'/Parameters_edit.mat'],'TX_HEIGHT','RX_HEIGHT','tworay_pathloss_alpha','tworay_pathloss_epsilon','TX_POWER','CARRIER_FREQ','nakagami_mu','nakagami_omega','EPSILON','ALPHA','fading_params','aprx_per','loss_vals','fading_bin_start_edges')
%% Parameters
d_max = 800;
TRUNCATION_VALUE=-94;
LIGHT_SPEED=3*10^8;
lambda=LIGHT_SPEED/CARRIER_FREQ;
%% Dataset prepare
display('Data Prepare Phase')
file_string = sprintf('%s/s %d %d o %d %d/data results/%s %s.csv','Seperated DensityPER',same_low_up,same_med_up,opposite_low_up,opposite_med_up,mode{1},mode{2});
input  = file_string;
file_name_string = sprintf('%s/%s Direction %s Density %d to %d',experiment_name,mode{1},mode{2},mode{3},mode{4});
csv_data = readtable(input,'ReadVariableNames',true);
dataset_mat_dirty = [csv_data.Range,csv_data.RSS];
any(isnan(dataset_mat_dirty))

any(dataset_mat_dirty(:)<-100)
dataset_cell_dirty = data_mat_cell(dataset_mat_dirty,d_max);
packet_loss_stat = per_calc(dataset_cell_dirty,-95);
per = packet_loss_stat(:,1)./packet_loss_stat(:,2);
dataset_cell = truncate_data_cell(dataset_cell_dirty,TRUNCATION_VALUE-1);
data_dbm_cell = dataset_cell;
data_dbm_cell = data_dbm_cell(1:d_max);
data_dbm_mean = funoncellarray1input(data_dbm_cell,@mean);
data_dbm_std = funoncellarray1input(data_dbm_cell,@std);

%% Pathloss
pathloss = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,EPSILON,ALPHA,lambda,d_max);
%% Extract Fading
data_fading_dbm = extract_fading(data_dbm_cell,pathloss,TX_POWER);
%% Generate Data
generated_fading_linear = nakagami_generator(fading_params,1e3);
generated_fading_dbm = linear2dbm(generated_fading_linear);
generated_rssi_dbm = add_fading(pathloss,generated_fading_dbm,TX_POWER);
generated_rssi_dbm_truncated = truncate_data_cell(generated_rssi_dbm,TRUNCATION_VALUE);
generated_rssi_dbm_mean = funoncellarray1input(generated_rssi_dbm,@mean);
generated_total_samples = funoncellarray1input(generated_rssi_dbm,@length);
generated_received_samples = funoncellarray1input(generated_rssi_dbm_truncated,@length);
generated_per = 1-(generated_received_samples./generated_total_samples);
%% Pathloss Compare Plot
figure;subplot(2,1,1);plot(generated_rssi_dbm_mean);hold;plot(data_dbm_mean);title('Mean Comparison');legend('Model','Field');subplot(2,1,2);plot(aprx_per);title('PER');saveas(gcf,['Plots/',file_name_string,'/','Mean Model vs Field.png']);
%% Percentile Plot
percentiles_generated = percentile_array([10,25,50,75,90],generated_rssi_dbm);
percentiles_generated_trunc = percentile_array([10,25,50,75,90],generated_rssi_dbm_truncated);
percentiles_rssi = percentile_array([10,25,50,75,90],data_dbm_cell);
figure;plot(percentiles_generated(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));grid on;legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI 10.png']);
figure;plot(percentiles_generated_trunc(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));grid on;legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI Truncated 10.png']);
figure;plot(percentiles_generated(:,[2,3,4]));hold on ;plot(percentiles_rssi(:,[2,3,4]));grid on;legend('25% model','50% model','75% model','25% field','50% field','75% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI 25.png']);
figure;plot(percentiles_generated_trunc(:,[2,3,4]));hold on ;plot(percentiles_rssi(:,[2,3,4]));grid on;legend('25% model','50% model','75% model','25% field','50% field','75% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI Truncated 25.png']);
%% PER Plot
figure;plot(packet_loss_stat(:,2));hold;plot(packet_loss_stat(:,2)-packet_loss_stat(:,1));grid on;title('Total Samples vs Received Samples');legend('Total Samples','Recieved Samples');saveas(gcf,['Plots/',file_name_string,'/','Samples Received vs Total.png']);
figure; plot(generated_per);hold on; plot(aprx_per);plot(packet_loss_stat(:,1)./packet_loss_stat(:,2));grid on;title('PER Value');legend('Generated Data','Smooth Field','Field','Location','northwest');saveas(gcf,['Plots/',file_name_string,'/','PER Comparison.png']);
figure;plot(loss_vals);title('loss');grid on;saveas(gcf,['Plots/',file_name_string,'/','Loss.png']);
%     figure;plot(loss_vals);title('loss');saveas(gcf,['Plots/',file_name_string,'/','Loss.png']);
%% Plot Nakagami Parameters
figure;plot(fading_params(:,1));title('Mu - Distance');grid on;saveas(gcf,['Plots/',file_name_string,'/','mu_distance.png']);
figure;plot(fading_params(:,2));title('Omega - Distance');grid on;saveas(gcf,['Plots/',file_name_string,'/','Omega_distance.png']);
%% Plot Normalized Likelihood
ll_fun_handle = @(x)loglikelihood_samples(x{1},'lognakagami',x{2},x{3});
fading_trunc_val_dbm = -94+pathloss-TX_POWER;
tmp_input_cell_array = {data_fading_dbm,fading_params,-inf*ones(length(generated_fading_dbm),1)};
ll_fading_dbm = funonarray(ll_fun_handle,tmp_input_cell_array);
tmp_input_cell_array = {data_fading_dbm,fading_params,fading_trunc_val_dbm'};
ll_fading_dbm_truncated = funonarray(ll_fun_handle,tmp_input_cell_array);
% Plot
figure;plot(ll_fading_dbm);hold on ;plot(ll_fading_dbm_truncated);grid on;title('Log Likelihood RSSI - Distance');legend('Full Distribution','Truncated Distribution');saveas(gcf,['Plots/',file_name_string,'/','LL RSSI.png']);