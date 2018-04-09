clc
close all
clear
addpath(genpath('.'))
%% File Names
mode_index =2;
for mode_index = 1:1
    
same_low_up = 15;
same_med_up = 40;

opposite_low_up = 15;
opposite_med_up = 40;

hov_include = 0;

 IX_EAST = {'InterX','East'};
    IX_WEST = {'InterX','West'};
    IX_SOUTH = {'InterX','South'};
    IX_NORTH = {'InterX','North'};
    MX_EAST = {'MidX','East'};
    MX_SOUTH = {'MidX','South'};
    mode_list = {IX_EAST,IX_WEST,IX_SOUTH,IX_NORTH,MX_EAST,MX_SOUTH};
mode = mode_list{mode_index};
experiment_name = 'Initial';
minimal_experiment_name = [mode{1},' Dir ',mode{2},' Density '];
% mode_name = [mode{1},' Direction ',mode{2},' Density ',num2str(mode{3}),' to ',num2str(mode{4})];
 mode_name = sprintf('%s %s',mode{1},mode{2});
parameter_folder = ['Plots/',experiment_name,'/',mode_name,'/Results'];
parameter_path = [parameter_folder,'/Parameters.mat'];
%% Load Params
load(parameter_path);
%% Parameters
d_max = 800;
TRUNCATION_VALUE=-94;
LIGHT_SPEED=3*10^8;
lambda=LIGHT_SPEED/CARRIER_FREQ;
%% Dataset prepare
display('Data Prepare Phase')
file_string = sprintf('Dataset/%s_Rx_at_%sLeg.csv',mode{1},mode{2});
    file_name_string = sprintf('%s/%s %s',experiment_name,mode{1},mode{2});
    
csv_data = readtable(file_string,'ReadVariableNames',true);
dataset_mat_dirty = [csv_data.TxRxDistance,csv_data.RSS];
dataset_mat_dirty(dataset_mat_dirty(:,2)>300,2) = -999;
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
figure;subplot(2,1,1);plot(generated_rssi_dbm_mean);hold;plot(data_dbm_mean);title([minimal_experiment_name,'Mean Comparison']);grid on;legend('Model','Field');subplot(2,1,2);plot(aprx_per);title('PER');ylabel('RSS');saveas(gcf,['Plots/',file_name_string,'/','Mean Model vs Field.png']);
%% Percentile Plot
percentiles_generated = percentile_array([10,25,50,75,90],generated_rssi_dbm);
percentiles_generated_trunc = percentile_array([10,25,50,75,90],generated_rssi_dbm_truncated);
percentiles_rssi = percentile_array([10,25,50,75,90],data_dbm_cell);
figure;plot(percentiles_generated(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));grid on;title([minimal_experiment_name,'Percentile']);title('RSSI Percentile');ylabel('RSS (dbm)');xlabel('Distance (m)');legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI 10.png']);
figure;plot(percentiles_generated_trunc(:,[1,3,5]));hold on ;plot(percentiles_rssi(:,[1,3,5]));grid on;title([minimal_experiment_name,'Truncated Percentile']);title('RSSI Percentile');ylabel('RSS (dbm)');xlabel('Distance (m)');legend('10% model','50% model','90% model','10% field','50% field','90% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI Truncated 10.png']);
figure;plot(percentiles_generated(:,[2,3,4]));hold on ;plot(percentiles_rssi(:,[2,3,4]));grid on;title([minimal_experiment_name,'Percentile']);title('RSSI Percentile');ylabel('RSS (dbm)');xlabel('Distance (m)');legend('25% model','50% model','75% model','25% field','50% field','75% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI 25.png']);
figure;plot(percentiles_generated_trunc(:,[2,3,4]));hold on ;plot(percentiles_rssi(:,[2,3,4]));grid on;title([minimal_experiment_name,'Truncated Percentile']);title('RSSI Percentile');ylabel('RSS (dbm)');xlabel('Distance (m)');legend('25% model','50% model','75% model','25% field','50% field','75% field');saveas(gcf,['Plots/',file_name_string,'/','Percentile RSSI Truncated 25.png']);
%% PER Plot
figure;plot(packet_loss_stat(:,2));hold;plot(packet_loss_stat(:,2)-packet_loss_stat(:,1));xlabel('Distance(m)');ylabel('Number of Samples');grid on;title([minimal_experiment_name,'Total Samples vs Received Samples']);legend('Total Samples','Recieved Samples');saveas(gcf,['Plots/',file_name_string,'/','Samples Received vs Total.png']);
% figure; plot(generated_per);hold on; plot(aprx_per);plot(packet_loss_stat(:,1)./packet_loss_stat(:,2));grid on;title([minimal_experiment_name,'PER Value']);legend('Generated Data','Smooth Field','Field','Location','northwest');saveas(gcf,['Plots/',file_name_string,'/','PER Comparison.png']);
figure; plot(generated_per);hold on;plot(packet_loss_stat(:,1)./packet_loss_stat(:,2));grid on;title([minimal_experiment_name,'PER Value Comparison']);ylabel('Rate');xlabel('Distance (m)');legend('Model','Field','Location','northwest');saveas(gcf,['Plots/',file_name_string,'/','PER Comparison.png']);
figure;plot(loss_vals);title([minimal_experiment_name,'loss']);grid on;saveas(gcf,['Plots/',file_name_string,'/','Loss.png']);
%     figure;plot(loss_vals);title('loss');saveas(gcf,['Plots/',file_name_string,'/','Loss.png']);
%% Plot Nakagami Parameters
figure;plot(fading_params(:,1));title([minimal_experiment_name,'Mu - Distance']);grid on;xlabel('Distance (m)');ylabel('Mu Value');saveas(gcf,['Plots/',file_name_string,'/','mu_distance.png']);
figure;plot(fading_params(:,2));title([minimal_experiment_name,'Omega - Distance']);grid on;xlabel('Distance (m)');ylabel('Omega Value');saveas(gcf,['Plots/',file_name_string,'/','Omega_distance.png']);
%% Plot Normalized Likelihood
ll_fun_handle = @(x)loglikelihood_samples(x{1},'lognakagami',x{2},x{3});
fading_trunc_val_dbm = -94+pathloss-TX_POWER;
tmp_input_cell_array = {data_fading_dbm,fading_params,-inf*ones(length(generated_fading_dbm),1)};
ll_fading_dbm = funonarray(ll_fun_handle,tmp_input_cell_array);
tmp_input_cell_array = {data_fading_dbm,fading_params,fading_trunc_val_dbm'};
ll_fading_dbm_truncated = funonarray(ll_fun_handle,tmp_input_cell_array);
% Plot
figure;plot(ll_fading_dbm);hold on ;plot(ll_fading_dbm_truncated);grid on;title([minimal_experiment_name,'Log Likelihood RSSI - Distance']);legend('Full Distribution','Truncated Distribution');saveas(gcf,['Plots/',file_name_string,'/','LL RSSI.png']);
%% KS-Test
h = funoncellarray2input(generated_rssi_dbm_truncated,data_dbm_cell,@(x,y)kstest2(x,y,'Alpha',.01));
figure;plot(h);title('KS-Test');xlabel('Distance (m)');ylim([-1,2]);ylabel('Null Hyphotesis State');grid on;saveas(gcf,['Plots/',file_name_string,'/','KS-Test.png']);
end