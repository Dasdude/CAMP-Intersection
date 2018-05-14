clc 
close all
clear
addpath(genpath('.'))
merge = 0;
if merge
    display('Merging All Intersection Data for Perpendicular')
    IX_EAST = {'InterX','East'};
    IX_WEST = {'InterX','West'};
    IX_SOUTH = {'InterX','South'};
    IX_NORTH = {'InterX','North'};
    MX_EAST = {'MidX','East'};
    MX_SOUTH = {'MidX','South'};
    mode_list = {IX_EAST,IX_WEST,IX_SOUTH,IX_NORTH};
    all_prependicular = [];
    mkdir('Dataset/Ehsan')
    for i = 1:length(mode_list)
        mode = mode_list{i}
        file_string = sprintf('Dataset/%s_Rx_at_%sLeg.csv',mode{1},mode{2});
        csv_data = readtable(file_string,'ReadVariableNames',true);
        csv_data = csv_data(strcmp(csv_data.LinkType,'NLOS_Perpendicular'),:);
        all_prependicular = [all_prependicular;csv_data];
    end
    writetable(all_prependicular,'Dataset/Ehsan/perp.csv')
else
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