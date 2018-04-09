clc
clearvars -except data_set
close all
clear

for mode_index = 1:1
    clearvars -except mode_index
    close all
    %% Constant Variables
    % Modes
    SAME_DENS_LOW = {'Same','Low','0','10',1.0043,2.0108};
    SAME_DENS_MED = {'Same','Medium','10','30',1.0091,2.0237};
    SAME_DENS_HIGH = {'Same','High','30','Inf',1.0036,2.0576};
    OP_DENS_LOW = {'Opposite','Low','0','10',1,2.1434};
    OP_DENS_MED = {'Opposite','Medium','10','25',1,2.1904};
    OP_DENS_HIGH = {'Opposite','High','25','Inf',1,2.26};
    mode_list = {SAME_DENS_LOW,SAME_DENS_MED,SAME_DENS_HIGH,OP_DENS_LOW,OP_DENS_MED,OP_DENS_HIGH};
    % Dataset variables
    d_min = 1;
    d_max = 800;
    % Model Variables
    FADING_BIN_SIZE = 20;
    TX_POWER = 20;
    CARRIER_FREQ=5.89*10^9;
    TX_HEIGHT = 1.4787;
    RX_HEIGHT = TX_HEIGHT;
    LIGHT_SPEED=3*10^8;
    TRUNCATION_VALUE= -94;
    lambda=LIGHT_SPEED/CARRIER_FREQ;
    %% File Preperation
    mode = mode_list{mode_index};
    file_string = [mode{1},' Direction ',mode{2},' Density ',mode{3},' to ',mode{4},'.csv'];
    file_name_string = ['Test/',mode{1},' Direction ',mode{2},' Density ',mode{3},' to ',mode{4}];
    mkdir(['Plots/',file_name_string]);
    %% Dataset prepare
    display('Data Prepare Phase')
    input  = file_string;
    csv_data = readtable(input,'ReadVariableNames',true);
    dataset_mat_dirty = [csv_data.Range,csv_data.RSS];
    any(dataset_mat_dirty(:)<-100)
    dataset_cell_dirty = data_mat_cell(dataset_mat_dirty,d_max);
    packet_loss_stat = per_calc(dataset_cell_dirty,-120);
    packet_loss_stat(:,1)=0;
    dataset_cell = truncate_data_cell(dataset_cell_dirty,-148);
    %% Pathloss Estimate
    display('Pathloss Estimation Phase')
    EPSILON = mode{5};
    ALPHA = mode{6};
    pathloss = pathloss_gen_2ray(TX_HEIGHT,RX_HEIGHT,EPSILON,ALPHA,lambda,d_max);
    %% Fading Parameter Estimate
    display('Fading Estimation Phase')
    fading_dbm_cell = extract_fading(dataset_cell,pathloss,TX_POWER);
    fading_linear_cell = dbm2linear(fading_dbm_cell);
    fading_params = fading_estimator_nakagami_mle_adptv_bin_bias(fading_linear_cell,[1,1,0],FADING_BIN_SIZE,d_min,packet_loss_stat,TRUNCATION_VALUE,100,packet_loss_stat(:,2));
%     shift_values_dbm = linear2dbm_mat(fading_params(:,3));
    %% Fading Distribution Generation
    fading_linear_generated_cell = nakagami_generator(fading_params,100);
    fading_dbm_generated_cell = linear2dbm(fading_linear_generated_cell);
    %% Add Fading
    data_generated_dbm_cell = add_fading(pathloss,fading_dbm_generated_cell,TX_POWER);
    %% Convert Cells to mat
    data_dbm_generated_mat = data_cell2mat(data_generated_dbm_cell);
    fading_dbm_generated_mat = data_cell2mat(fading_dbm_generated_cell);
    fading_dbm_mat = data_cell2mat(fading_dbm_cell);
    data_dbm_mat = data_cell2mat(dataset_cell);
    %% Plot fading
    box_plot_2(fading_dbm_mat,fading_dbm_generated_mat,'GT','Nakagami',d_min,d_max,'Fading-Distance',file_name_string)
    box_plot_2(data_dbm_mat,data_dbm_generated_mat,'GT','Nakagami',d_min,d_max,'RSSI-Distance',file_name_string)
    %% Plot PER
    per_plot(packet_loss_stat(:,1)./packet_loss_stat(:,2),d_min,d_max,'PER',file_name_string)
    figure;plot(packet_loss_stat(:,2));title('Total Samples');saveas(gcf,['Plots/',file_name_string,'/','Total Samples.png']);
end
    