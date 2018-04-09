clc 
clear
close all
grid on
%% Density Bounds
same_low_up = 15;
same_med_up = 30;
same_high_down = same_med_up;same_low_down = 0;same_high_up = inf;same_med_down = same_low_up;

opposite_low_up = 15;
opposite_med_up = 30;
opposite_high_down = opposite_med_up;opposite_low_down = 0;opposite_high_up = inf;opposite_med_down = opposite_low_up;
%% Data Path
dataset_name = 'DatasetMerged/data_merged.csv';
all_data = readtable(dataset_name,'ReadVariableNames',true);
addpath(genpath('.'))
addpath(genpath('./..'))
experiment_name = sprintf('s %d %d o %d %d',same_low_up,same_med_up,opposite_low_up,opposite_med_up);
file_name_string = sprintf('%s/%s/','Seperated DensityPER',experiment_name);
% file_name_string = ['Seperated DensityPER/s';
mkdir(file_name_string)
sanity_check =0;
%% Add Side West is one and East Is zero
all_data.ego_side(:) = 0;
all_data.contact_side(:) = 0;
all_data.ego_side(all_data.rxlat>=33.7743&all_data.rxlong>=-118.06)=1;
all_data.ego_side(all_data.rxlat>=33.77435&all_data.rxlong<=-118.06)=1;
all_data.contact_side(all_data.lat>=33.7743&all_data.long>=-118.06)=1;
all_data.contact_side(all_data.lat>=33.77435&all_data.long<=-118.06)=1;
all_data.Av_East_Density = all_data.East_Total./8;
all_data.Av_West_Density = all_data.West_Total./8;

%% Seperate Encounter Scenario
same_lane_indicator = ((all_data.ego_side==0)&(all_data.contact_side==0))|((all_data.ego_side==1)&(all_data.contact_side==1));
opposite_lane_indicator = ~same_lane_indicator;
same_lane = all_data(same_lane_indicator,:);
opposite_lane = all_data(opposite_lane_indicator,:);

same_lane.average_density(same_lane.ego_side<1)=same_lane.Av_East_Density(same_lane.ego_side<1);
same_lane.average_density(same_lane.ego_side>0)=same_lane.Av_West_Density(same_lane.ego_side>0);
opposite_lane.average_density = (opposite_lane.Av_East_Density+opposite_lane.Av_West_Density)./2;
if sanity_check

    figure;scatter(all_data.rxlat(all_data.rxlat>=33.7743),all_data.rxlong(all_data.rxlat>=33.7743),1,all_data.ego_side(all_data.rxlat>=33.7743));
    figure;scatter(opposite_lane.rxlat,opposite_lane.rxlong,1,opposite_lane.ego_side);
    figure;scatter(opposite_lane.lat,opposite_lane.long,1,opposite_lane.contact_side);
    figure;scatter(same_lane.rxlat,same_lane.rxlong,1,same_lane.ego_side);
    figure;scatter(opposite_lane.lat,opposite_lane.long,1,opposite_lane.contact_side);

end

%% Same Dir Process
same_lane.RSS(same_lane.RSS==-150)=-101;
same_lane_clean = same_lane;
same_lane_mat = [same_lane_clean.Range,same_lane_clean.RSS];
density_indexes = 0:5:45;
rss_mean = zeros(800,5);
figure;
for d = 1:5
    d_min = (d-1)*10;
    d_max = d*10;
    same_lane_density_crop = same_lane_clean(same_lane_clean.average_density>=d_min&same_lane_clean.average_density<d_max,:);
    same_lane_mat = [same_lane_density_crop.Range,same_lane_density_crop.RSS];
    same_lane_cell = data_mat_cell(same_lane_mat,800);
%     rss_mean(:,d) = funoncellarray1input(same_lane_cell,@mean);
    rss_mean(:,d) = percentile_array([50],same_lane_cell);
    
%     rss_mean(:,d) =mean(same_lane_clean.RSS(same_lane_clean.average_density>d_min&same_lane_clean.average_density<d_max));
end
plot(rss_mean);legend()