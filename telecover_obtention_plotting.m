%% This code aims to read telecover data and plot its profiles for each channel.

% Telecover date of measurement
day = 27; month = 09; year = 2022;
%root_folder = 'C:\\Users\\paguirrea\\Desktop\\Práctica Pablo 2022-2\\Códigos MATLAB editados por Pablo\\Datos para procesamiento LIDAR 2022-2_practica\\%d\\%02d\\%02d';
root_folder = 'C:\\Users\\usuario\\OneDrive - Universidad EAFIT\\Códigos LIDAR pablo\\Datos para procesamiento\\%d\\%02d\\%02d';
path_lidar = sprintf(root_folder, year, month, day);        % in root_folder prints year,month,day as a format ( {}.format python )

%% Choose date of Dark current characterization

path_lidar = sprintf(root_folder, year, month, day);
dark_current_path = strcat(path_lidar,'\DC');

if exist(dark_current_path)
    dark_current = open_files(dark_current_path);                               % Aquí se abren todos los archivos contenidos en la ruta...\04\13\DC y sus datos quedan guardados en una matriz 2-dim. En una capa pol p, en la otra pol s.
    DC = mean(dark_current,2);                                                         % Devuelve en un vector columna la media de cada fila
end

tmp = dir(dark_current_path);
tmp=tmp(~ismember({tmp.name},{'.','..','temp.dat.txt'}));

file_names_DC(1 : length(tmp)) = {""}; %#ok<STRSCALR>


%% Dark current filtered signal  (DC_filtered creation)
v = isoutlier(DC,'quartiles');
DC_filt = DC;
for bin_index=1:size(DC,1)
    for channel_index=1:size(DC,3)
        if v(bin_index,1,channel_index)==1
           DC_filt(bin_index,1,channel_index) = mean(DC(:,:,channel_index));
        end             
    end
end

%%
%%format long;
DC(1:29, :, :) = [];

R = 0:3.75:61315;
R = R';

Q1_path = strcat(path_lidar,'\Prueba de alineacion\RS\Q1A');
Q1 = open_files(Q1_path);
Q1 = mean(Q1, 2);
Q1(1:29, :, :) = [];
Q1 = abs(Q1 - DC);
% Q1(1500:end, :, :) =  Q1(1500:end, :, :) .* mean(Q1(10000:end, :, :))*0.00001;
% Q1(:, :, 1) = smooth(Q1(:, :, 1), 0.05, 'rloess');
RCS_Q1 = Q1 .* R.^2;

Q1B_path = strcat(path_lidar,'\Prueba de alineacion\RS\Q1B');
Q1B = open_files(Q1B_path);
Q1B = mean(Q1B, 2);
Q1B(1:29, :, :) = [];
Q1B = abs(Q1B - DC);
RCS_Q1B = Q1B .* R.^2;

Q2_path = strcat(path_lidar,'\Prueba de alineacion\RS\Q2');
Q2 = open_files(Q2_path);
Q2 = mean(Q2, 2);
Q2(1:29, :, :) = [];
Q2 = abs(Q2 - DC);
RCS_Q2 = Q2 .* R.^2;

Q3_path = strcat(path_lidar,'\Prueba de alineacion\RS\Q3');
Q3 = open_files(Q3_path);
Q3 = mean(Q3, 2);
Q3(1:29, :, :) = [];
Q3 = abs(Q3 - DC);
RCS_Q3 = Q3 .* R.^2;
% 
% Q3B_path = strcat(path_lidar,'\Q3B');
% Q3B = open_files(Q3B_path);
% Q3B = mean(Q3B, 2);

Q4_path = strcat(path_lidar,'\Prueba de alineacion\RS\Q4');
Q4 = open_files(Q4_path);
Q4 = mean(Q4, 2);
Q4(1:29, :, :) = [];
Q4 = abs(Q4 - DC);
RCS_Q4 = Q4 .* R.^2;

%% Maximum bin finder

Q = {Q1(:,:,:) Q2(:,:,:) Q3(:,:,:) Q4(:,:,:) Q1B(:,:,:)};   
bin_v = cell(2,length(Q)); 
for channel=1:2
    for index=1:length(Q)
        for bin=1:101
            if max(Q{index}(:,:,channel))== Q{index}(bin,:,channel) 
                Q{index}(bin,:,channel); bin_v{channel,index} = bin-1;
            end
        end
    end
end

%% Channel 0 plotting

telecover_fig = figure('Color','white', 'units', 'normalized', 'outerposition', [0 0 1 1]);

% telecover_plot = plot(0:length(Q1(1:101, :, 1)) - 1, Q1(1:101, :, 1), 'LineWidth', 2, 'Color', 'k');
telecover_plot = plot(0:length(Q1(1:101, :, 1)) - 1, Q1(1:101, :, 1), 'LineWidth', 3, 'Color', 'k');
hold on
Q2_plot = plot(0:length(Q2(1:101, :, 1)) - 1, Q2(1:101, :, 1), 'LineWidth', 3, 'Color', '#006600');
Q3_plot = plot(0:length(Q3(1:101, :, 1)) - 1, Q3(1:101, :, 1), 'LineWidth', 3, 'Color', 'r');
Q4_plot = plot(0:length(Q4(1:101, :, 1)) - 1, Q4(1:101, :, 1), 'LineWidth', 3, 'Color', 'b');
Q1B_plot = plot(0:length(Q1B(1:101, :, 1)) - 1, Q1B(1:101, :, 1), 'LineWidth', 3, 'Color', 'm');


xticks(0:5:100)
% yticks(5:0.5:15)
% ytickformat('%.1f')
grid('on')
ax = gca;
ax.FontSize = 20;

ylabel('Raw signal [mV]', 'FontSize', 24)
xlabel('Bin', 'FontSize', 24)
test_date = datetime(year, month, day);
test_date.Format = 'dd MMMM yyyy';
title(strcat('Telecover Test - ', {' '}, char(test_date), ' - Medellín - LiMon', 'Channel 0 - 532.p nm'), 'FontSize', 25)
leg1 = strcat('North. Bin= ',num2str(bin_v{1,1})); leg2 = strcat('East. Bin= ',num2str(bin_v{1,2})); 
leg3 = strcat('West. Bin= ',num2str(bin_v{1,3})); leg4 = strcat('South. Bin= ',num2str(bin_v{1,4}));
leg5 = strcat('North2. Bin= ',num2str(bin_v{1,5}));

legend(leg1, leg2, leg3, leg4, leg5, 'FontSize', 22);

outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - 1.1*ti(1) - 1.1*ti(3);
ax_height = outerpos(4) - 1.05*ti(2) - 1.05*ti(4);
ax.Position = [left bottom ax_width ax_height];

set(gcf, 'Units', 'inches');
screenposition = get(gcf, 'Position');
set(gcf, 'PaperPosition', [0 0 screenposition(3:4)], 'PaperSize', screenposition(3:4));


%% Channel 1 plotting

telecover_fig_CH1 = figure('Color','white', 'units', 'normalized', 'outerposition', [0 0 1 1]);

telecover_plot_CH1 = plot(0:length(Q1(1:101, :, 2)) - 1, Q1(1:101, :, 2), 'LineWidth', 3, 'Color', 'k');
hold on
Q2_plot_CH1 = plot(0:length(Q2(1:101, :, 2)) - 1, Q2(1:101, :, 2), 'LineWidth', 3, 'Color', '#006600');
Q3_plot_CH1 = plot(0:length(Q3(1:101, :, 2)) - 1, Q3(1:101, :, 2), 'LineWidth', 3, 'Color', 'r');
Q4_plot_CH1 = plot(0:length(Q4(1:101, :, 2)) - 1, Q4(1:101, :, 2), 'LineWidth', 3, 'Color', 'b');
Q1B_plot_CH1 = plot(0:length(Q1B(1:101, :, 2)) - 1, Q1B(1:101, :, 2), 'LineWidth', 3, 'Color', 'm');

xticks(0:5:100)
% yticks(5:0.5:15)
% ytickformat('%.1f')
grid('on')
ax = gca;
ax.FontSize = 20;

ylabel('Raw Signal [mV]', 'FontSize', 24)
xlabel('Bin', 'FontSize', 24)
test_date = datetime(year, month, day);
test_date.Format = 'dd MMMM yyyy';
title(strcat('Telecover Test - ', {' '}, char(test_date), ' - Medellín - LiMon', 'Channel 1 - 532.p nm'), 'FontSize', 25)

leg1 = strcat('North. Bin= ',num2str(bin_v{2,1})); leg2 = strcat('East. Bin= ',num2str(bin_v{2,2})); 
leg3 = strcat('West. Bin= ',num2str(bin_v{2,3})); leg4 = strcat('South. Bin= ',num2str(bin_v{2,4}));
leg5 = strcat('North2. Bin= ',num2str(bin_v{2,5}));
legend(leg1, leg2, leg3, leg4, leg5, 'FontSize', 22);

outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - 1.1*ti(1) - 1.1*ti(3);
ax_height = outerpos(4) - 1.05*ti(2) - 1.05*ti(4);
ax.Position = [left bottom ax_width ax_height];

set(gcf, 'Units', 'inches');
screenposition = get(gcf, 'Position');
set(gcf, 'PaperPosition', [0 0 screenposition(3:4)], 'PaperSize', screenposition(3:4));

