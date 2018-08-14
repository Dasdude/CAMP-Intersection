function [same_leg_flag_res,nsame_los_flag_res,nsame_nlos_flag_res] = insquare(data_table)
%INSQUARE determines whether transmitter and recievers line of sight line is
%within the square
%   transmitter and reciever should be nx2 
%   isinsqure is 1x
% [lat,long]
% is_insquare_res = zeros(height(data_table),1);
same_leg_flag_res = zeros(height(data_table),1);
nsame_los_flag_res = zeros(height(data_table),1);
nsame_nlos_flag_res =zeros(height(data_table),1);
batch_size = 1000000;
    for s_idx = 1:batch_size:height(data_table)
        e_idx = min(s_idx+batch_size-1,height(data_table))
        sq_vertice = [33.759453,-117.989372;%a
                  33.759423,-117.990004;%b
                  33.759121,-117.989391;%b
                  33.759104,-117.989955];%a ( same letters are diagonal vertices)
        transmitter_table = [data_table(s_idx:e_idx,'TxLat'),data_table(s_idx:e_idx,'TxLon')];
        reciever_table = [data_table(s_idx:e_idx,'RxLat'),data_table(s_idx:e_idx,'RxLon')];
        transmitter = table2array(transmitter_table);
        clear transmitter_table;
        reciever = table2array(reciever_table);
        clear reciever_table
        [square_m,square_bias]  = get_line_from2points(sq_vertice([1,2],:),sq_vertice([4,3],:));
        [tr_line_m , tr_line_bias] = get_line_from2points(transmitter,reciever);
        los_signs = sign(projectpoint_on_lines(tr_line_m,tr_line_bias,sq_vertice));
        nlos_flag = (abs(sum(los_signs))==4)';
        % clear data_table;
%         m = transmitter-reciever ;
%         m = [-m(:,2),m(:,1)];
%         bias = -sum((m.*transmitter)');

        % m_dummy= m(idx,:);
        % bias_dummy = bias(idx);
        % pr_dummy = sq_vertice*m_dummy'+bias_dummy;
        % pr_flag_dummy = pr_dummy<0;
    %     clear data_table
%         pr = sq_vertice*m'+bias;
%         pr_flag = pr<0;
%         is_insquare = ~(all(pr_flag)+all(~pr_flag));
        tr_po_flag = sign(projectpoint_on_lines(square_m,square_bias,transmitter));
        rec_pos_flag = sign(projectpoint_on_lines(square_m,square_bias,reciever));
        same_leg_flag = tr_po_flag == rec_pos_flag;
        same_leg_flag = same_leg_flag(:,1)&same_leg_flag(:,2);
        nsame_leg_flag = ~same_leg_flag;
        nsame_los_flag = ~nlos_flag&nsame_leg_flag;
        nsame_nlos_flag = nlos_flag&nsame_leg_flag;
%         same_leg_flag = strcmp(data_table.RxLocation,data_table.TxLocation);
%         is_insquare_res(s_idx:e_idx,:) =is_insquare'|same_leg_flag;
%         is_insquare_res(s_idx:e_idx,:) =same_leg_flag;
        same_leg_flag_res(s_idx:e_idx,:)  = same_leg_flag;
        nsame_los_flag_res(s_idx:e_idx,:) =nsame_los_flag;
        nsame_nlos_flag_res(s_idx:e_idx,:) = nsame_nlos_flag;
        
    end
    same_leg_flag_res = boolean(same_leg_flag_res);
    nsame_nlos_flag_res = boolean(nsame_nlos_flag_res);
    nsame_los_flag_res = boolean(nsame_los_flag_res);
    
end

