clc
close all
clear
file_name_string = 'Synthetic';
mkdir(['Plots/',file_name_string]);
dataset_folder = 'SyntheticDataset'
experiment_name = 'Gaussian';
dataset_folder = [dataset_folder,'/',experiment_name];
mkdir(dataset_folder);
%% Experiment params
d_max = 800;
samples_per_meter = 1e3;
%% Pathloss Params
epsilon= 1.002;
alpha = 2.432;
TX_POWER = 20;
CARRIER_FREQ=5.89*10^9;
TX_HEIGHT = 1.4787;
RX_HEIGHT = TX_HEIGHT;
LIGHT_SPEED=3*10^8;
lambda = LIGHT_SPEED./CARRIER_FREQ;
trunc_val = -94;
%% Fading Params
max_mu = 4;
mu_noise_std = 1;
mu_noise_mean = 0;
mu_noise = (mu_noise_std*randn([1,d_max]))+mu_noise_mean;
fading_params_mu = (max_mu.*[1:d_max]./d_max)+mu_noise;

max_sigma = 6;
sigma_noise_std = 1;
sigma_noise_mean = 0;
sigma_denoise=(max_sigma.*[1:d_max]./d_max);
sigma_noise = (sigma_noise_std*randn([1,d_max]))+sigma_noise_mean;
fading_params_sigma = sigma_denoise+sigma_noise;
%% Variables
fading_dbm_cell  =  cell(1,d_max);
rssi_dbm_cell = cell(1,d_max);
figure;plot(1:d_max,fading_params_sigma,1:d_max,fading_params_mu);legend('Sigma','MU');
%% Create Pathloss
pathloss_baseline = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,epsilon,alpha,lambda,d_max);
%% Create Fading

for i = 1:d_max
    fading_dbm_cell{i} = (fading_params_sigma(i)*randn([1,samples_per_meter]))+fading_params_mu(i);
end
fading_dbm_mat = data_cell2mat(fading_dbm_cell);
box_plot_2(fading_dbm_mat,fading_dbm_mat,'GT','r','Nakagami','b',1,d_max,'Fading(dbm)-Distance',file_name_string,10,'on');

for i = 1:d_max
    rssi_dbm_cell{i} = TX_POWER-pathloss_baseline(i)+fading_dbm_cell{i};
end
rssi_dbm_mat = data_cell2mat(rssi_dbm_cell);
box_plot_2(rssi_dbm_mat,rssi_dbm_mat,'GT','r','Nakagami','b',1,d_max,'Fading(dbm)-Distance',file_name_string,10,'on');
rss_dbm_truncated_cell = truncate_data_cell(rssi_dbm_cell,-94);

%%
test_alpha = alpha;
test_epsilon = epsilon;
test_gaussian_mu = fading_params_mu;
test_gaussian_omega = fading_params_sigma;
train_rss_dbm_truncated_cell = rss_dbm_truncated_cell;
train_total_recieved_samples = funoncellarray1input(rss_dbm_truncated_cell,@length);
train_total_samples = funoncellarray1input(rssi_dbm_cell,@length);
train_per = 1-(train_total_recieved_samples./train_total_samples);

figure;
plot(train_per);
save([dataset_folder,'/syn_parameters_dataset.mat'],'test_alpha','test_epsilon','test_gaussian_mu','test_gaussian_omega','train_rss_dbm_truncated_cell','train_total_recieved_samples','train_total_samples','train_per');

% variable_names = {'fading_dbm_cell','rss_dbm_cell','rss_dbm_truncated_cell',
% save(