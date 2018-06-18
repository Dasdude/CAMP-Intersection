clc 
close all
clear
addpath(genpath('.'))
merge = 2;
if merge==0
    display('Merging All Intersection Data for Perpendicular')
    IX_EAST = {'InterX','East'};
    IX_WEST = {'InterX','West'};
    IX_SOUTH = {'InterX','South'};
    IX_NORTH = {'InterX','North'};
    MX_EAST = {'MidX','East'};
    MX_SOUTH = {'MidX','South'};
    mode_list = {IX_EAST,IX_WEST,IX_SOUTH,IX_NORTH,MX_EAST,MX_SOUTH};
    all_prependicular = [];
    mkdir('Dataset/Ehsan')
    for i = 1:length(mode_list)
        mode = mode_list{i}
        file_string = sprintf('Dataset/%s_Rx_at_%sLeg.csv',mode{1},mode{2});
        csv_data = readtable(file_string,'ReadVariableNames',true);
        csv_data = clean_intersection_data(csv_data);
        csv_data = csv_data(:,{'Timestamp','RSS','RxLat','RxLon','TxLat','TxLon','TxRxDistance','TxLocation','RxLocation'});
%         csv_data = csv_data(strcmp(csv_data.LinkType,'NLOS_Perpendicular'),:);
        all_prependicular = [all_prependicular;csv_data];
    end
    writetable(all_prependicular,'Dataset/Ehsan/all.csv')
end
if merge ==1
    data_merged = readtable('Dataset/Ehsan/perp.csv','ReadVariableNames',true);
    se_flag = (strcmp(data_merged.RxLocation,'East')&strcmp(data_merged.TxLocation,'South'))|(strcmp(data_merged.TxLocation,'East')&strcmp(data_merged.RxLocation,'South'));
    nw_flag = (strcmp(data_merged.RxLocation,'West')&strcmp(data_merged.TxLocation,'North'))|(strcmp(data_merged.TxLocation,'West')&strcmp(data_merged.RxLocation,'North'));
    nesw_flag = ~(se_flag|nw_flag);
    
    data_merged_se = data_merged(se_flag,:);
    data_merged_nw = data_merged(nw_flag,:);
    data_merged_nesw = data_merged(nesw_flag,:);
    
    writetable(data_merged_se,'Dataset/Ehsan/South East.csv');
    writetable(data_merged_nw,'Dataset/Ehsan/North West.csv');
    writetable(data_merged_nesw,'Dataset/Ehsan/NorthEast SouthWest.csv');
end
if merge ==2
    data_merged_fixed = readtable('Dataset/Ehsan/all.csv','ReadVariableNames',true);
%     data_merged_fixed = clean_intersection_data(data_merged);
    [same_leg_flag,nsame_los_flag,nsame_nlos_flag] = insquare(data_merged_fixed);
    same_leg_data = data_merged_fixed(same_leg_flag,:);
    dif_leg_los_data = data_merged_fixed(nsame_los_flag,:);
    dif_leg_nlos_data = data_merged_fixed(nsame_nlos_flag,:);
    per_roadmap_heatmap(data_merged_fixed,20,2,'./Plots/DataAnalysis/All/');
    per_roadmap_heatmap(dif_leg_nlos,20,2,'./Plots/DataAnalysis/NLOS');
    per_roadmap_heatmap(dif_leg_los,20,2,'./Plots/DataAnalysis/LOS');
    per_roadmap_heatmap(same_leg_data,20,2,'./Plots/DataAnalysis/SAME');
    plot_roadmap_transreciev(data_merged_fixed,10000,'All');
    close all
    plot_roadmap_transreciev(dif_leg_nlos_data,10000,'NLOS',0);
    close all;
    plot_roadmap_transreciev(dif_leg_los_data,10000,'LOS',0);
    close all;
    plot_roadmap_transreciev(same_leg_data,10000,'SameLeg',0);

    writetable(same_leg_data,'Dataset/Ehsan/same_leg.csv');
    writetable(dif_leg_los_data,'Dataset/Ehsan/dif_leg_los.csv');
    writetable(dif_leg_nlos_data, 'Dataset/Ehsan/dif_leg_nlos.csv');
end