%% This function aims to calculate the particle and volume depolarization ratio from calibration data
% Dark current of the calibration day readinf

%% Deletion of old variables in workspace, console and closure of active figures
clear
clearvars
clc
warning('off')
close all

%% Data reading

% Date of measurements to process:
day = 03;
month = 12;
year = 2022;

%root_folder = 'C:\\Users\\paguirrea\\Desktop\\Práctica Pablo 2022-2\\Códigos MATLAB editados por Pablo\\Datos para procesamiento LIDAR 2022-2_practica\\%d\\%02d\\%02d';
root_folder = 'C:\\Users\\usuario\\OneDrive - Universidad EAFIT\\Códigos LIDAR pablo\\Datos para procesamiento\\%d\\%02d\\%02d';
path_lidar = sprintf(root_folder, year, month, day);        % in root_folder prints year,month,day as a format ( {}.format python )

%% Calibration profile

% Useful variables for plotting are defined:
trigger_delay_bins = 28;
altitude = 0:3.75:61318.75;
altitude = altitude';

% Dark Current is read for filtering raw signal
dark_current_path = strcat(path_lidar,'\DC');
dark_current = open_files(dark_current_path);
dark_current = mean(dark_current, 2);
dark_current(1:trigger_delay_bins, :, :) = [];

% P45 signal reading:
calib_P45_path = strcat(path_lidar,'\CALIB\P45');
calib_P45 = open_files(calib_P45_path);
calib_P45 = mean(calib_P45, 2);                                             % Integrated P45 profile
calib_P45(1:trigger_delay_bins, :, :) = [];
calib_P45(:,:,1) = abs(calib_P45(:,:,1) - dark_current(:,:,1));         % I_T(+45°) - DC_T
calib_P45(:,:,2) = abs(calib_P45(:,:,2) - dark_current(:,:,2));         % I_R(+45°) - DC_R

% M45 signal reading: 
calib_M45_path = strcat(path_lidar,'\CALIB\M45');
calib_M45 = open_files(calib_M45_path);
calib_M45 = mean(calib_M45, 2);                                            % Integrated M45 profile
calib_M45(1:trigger_delay_bins, :, :) = [];
calib_M45(:,:,1) = abs(calib_M45(:,:,1) - dark_current(:,:,1));       % I_T(-45°) - DC_T
calib_M45(:,:,2) = abs(calib_M45(:,:,2) - dark_current(:,:,2));       % I_R(-45°) - DC_R

% Gain ratio calculation:
gain_ratio_P45 = calib_P45(:, :, 2) ./ calib_P45(:, :, 1);              % n*(+45°) = I_R(+45°)/I_T(+45°)
gain_ratio_M45 = calib_M45(:, :, 2) ./ calib_M45(:, :, 1);           % n*(-45°) = I_R(-45°)/I_T(-45°)
gain_ratio_M45(gain_ratio_M45 > 10) = mean(gain_ratio_M45);
gain_ratio_P45(gain_ratio_P45 > 1.8) = mean(gain_ratio_P45(1:266));
gain_ratio_M45(570:610) = mean(gain_ratio_M45); 
gain_ratio_M45 = smooth(gain_ratio_M45, 0.0009,'loess');
K_const = 1;
delta90_gain_ratio = sqrt(gain_ratio_M45 .* gain_ratio_P45)/K_const;  % n*d90 = sqrt(n*(+45°) n*(-45°))

%% Calibration profile plotting

% Figure creation and plotting
depol_calib = figure('Color','white');
% gain_ratio_M45(570:610) = nan;
GR_P45_plot = plot(gain_ratio_P45(1:2133), altitude(1:2133),'LineWidth', 0.8, 'Color', 'k');
hold on
GR_M45_plot = plot(gain_ratio_M45(1:2133), altitude(1:2133), 'LineWidth', 0.8, 'Color', 'b');
GR_delta90_plot = plot(delta90_gain_ratio(1:2133), altitude(1:2133), 'LineWidth', 1, 'Color', 'r');

% Basic figure configuration (legend, axis and title):
legend('\eta^*(+45)', '\eta^*(-45)', '\eta_{\Delta 90}');
xlim([min(gain_ratio_M45)-0.2 max(gain_ratio_M45)+0.2]);xticks(0:0.2:1); ax_1 = gca; ax_1.FontSize = 14;
xlabel('Gain ratio', 'FontSize', 18); ylabel('Altitude a.g.l [m]', 'FontSize', 18)
test_date = datetime(year, month, day); test_date.Format = 'dd MMMM yyyy';
title(strcat('Depolarization calibration - ', {' '}, char(test_date), ' - Medellín - LiMon'), 'FontSize', 22)

%% Raw signal lecture
% Here is read the raw signal of any other day in order to find its delta_v and delta_p.

day = 11; month = 04; year = 2022;
%root_folder = 'C:\\Users\\paguirrea\\Desktop\\Práctica Pablo 2022-2\\Códigos MATLAB editados por Pablo\\Datos para procesamiento LIDAR 2022-2_practica\\%d\\%02d\\%02d';
root_folder = 'C:\\Users\\usuario\\OneDrive - Universidad EAFIT\\Códigos LIDAR pablo\\Datos para procesamiento\\%d\\%02d\\%02d';
path_lidar = sprintf(root_folder, year, month, day);                     % in root_folder prints year,month,day as a format ( {}.format python )

raw_signal_path = strcat(path_lidar,'\RS');                                   % strcat -> stands for string concatenation (Adds "\RS" to the string contained in path_lidar)
if exist(raw_signal_path)                                                             % Only executes if there exists RS data for the selected day
    raw_signal = open_files(raw_signal_path);                               % open_files is a function in .m format saved in the current directory/repository
end

tmp = dir(raw_signal_path);                                                        % dir function lists the files in the directory
tmp=tmp(~ismember({tmp.name},{'.','..','temp.dat.txt'}));            % dir lists 2 files by default called ('.' and '..') that we delete. 'temp.dat' created by LICEL is also deleted in this line

file_names_RS(1 : length(tmp)) = {""}; %#ok<STRSCALR>            % Creates as many empty cells as RS files read for the selected day

% Filling of empty cells with the files names:
for file = 1 : length(tmp)
    file_names_RS(file) = cellstr(strcat(tmp(file).folder, '\', tmp(file).name));        % The string where the directory's name is saved, is concatenated with the name of the individual listed file name
end                       

%% Dark current (DC) directory reading and dark_current/DC creation

dark_current_path = strcat(path_lidar,'\DC');                                                % strcat -> stands for string concatenation (Adds "\DC" to the string contained in path_lidar)

% Asks if there is Dark Current data saved in the current directory, if not, then a directory with the needed data is searched:
if exist(dark_current_path)
    dark_current = open_files(dark_current_path);                               
elseif ~exist(dark_current_path, 'dir')     
    % Search for DC data measured on a different date:
    dark_current_path = 'C:\Users\paguirrea\Desktop\Práctica Pablo 2022-2\Códigos MATLAB editados por Pablo\Datos para procesamiento LIDAR 2022-2_practica\DC';
    tmp = dir(dark_current_path);
end

file_names_DC(1 : length(tmp)) = {""}; %#ok<STRSCALR>                             % Creates as many empty cells as DC files read for the selected day

% Filling of empty cells with the files names:
for file = 1 : length(tmp)                                                                                
    file_names_DC(file) = cellstr(strcat(tmp(file).folder, '\', tmp(file).name));      % The string where the directory's name is saved, is concatenated with the name of the individual listed file name
end      

DC = mean(dark_current,2);                                                                          % Returns a column vector whose elements are the mean value of each row of the original dark_current matrix

tmp = dir(dark_current_path);                                                                       % dir function lists the files in the directory
tmp=tmp(~ismember({tmp.name},{'.','..','temp.dat.txt'}));                               % dir lists 2 files by default called ('.' and '..') that we delete. 'temp.dat' created by LICEL is also deleted in this line                                                                                                      
                                               

%% Signal matrix creation and DC & DC_filtered correction
signal = zeros(size(raw_signal(trigger_delay_bins:end, :, :)));         
signal_filt = signal;

for channel = 1 : size(raw_signal, 3)
    for file_index = 1 : size(raw_signal, 2)
        signal(:, file_index, channel) = raw_signal(trigger_delay_bins:end, file_index, channel) - DC(trigger_delay_bins:end, 1, channel);  % Se omiten 34 elementos iniciales pues son trigger delay
    end
end

signal_CH0 = abs(signal(:,:,1)); signal_CH1 = abs(signal(:,:,2));

%% Request the user for how many profiles want to integrate
n = input('Please insert how many profiles do you want to retrieve: ')
options = cell(1,2*n);
v = [1:n]; v = sort([v,v]);     % Vector for saving profiles quantities

% Time interval definition
num_of_files = size(file_names_RS,2);
Fhora = zeros(1,size(file_names_RS,2));
for file_index = 1:num_of_files
    Fhora(1,file_index) = str2num(file_names_RS{file_index}(end-12:end-8));                             
end

local_time = Fhora;                             % In this vector, the time is saved
date = datetime(year, month, day);
date.Format = 'dd MMM yyyy';
wavelength = '532';
start_hour = num2str(min(Fhora)); 
end_hour = num2str(max(Fhora));

for i =1:2*n
    if mod(i,2) == 1
        options{1,i} = strcat('Enter initial file for profile',' - ',num2str(v(i)));
    elseif mod(i,2) == 0
        options{1,i} = strcat('Enter ending file for profile ','- ',num2str(v(i)));
    end
end

% Menu configuration
dlgtitle = 'Input';     
dims = [1 50];      % Width and height of the box
files_time = inputdlg(options,dlgtitle,dims);

%% Volume depolarization ratio obtention

app_delta_v = (1./ delta90_gain_ratio) .* (signal_CH1(1:end-1,:) ./ signal_CH0(1:end-1,:));         % Apparent volume depolarization ratio

GT = 1;
GR = 1;
HT = 1;
HR = -1;

delta_v = ((app_delta_v.* (GT + HT)) - (GR + HR)) ./ ((GR - HR) - (app_delta_v.* (GT - HT)));

%%
% Menu creation and selection of the titles for the figures:
user_choice = menu('Choose the optical product profile you want to display: ', 'Volume depolarization ratio','Particle depolarization ratio');

switch (user_choice)
    case 1
        quantity_index = 1;
    case 2
        quantity_index = 2;    
end

f = figure('Color','white');
color_list = ['r','b','k','m','c']; col_n = 1;                  % These letters indicate the color of each profile
R = 1:3.75:(3.75*size(delta_v));                              % Height vector

Legend = cell(n,1);
for iter = 1:n
    % init_f: is the number of the first file to analyse
    % end_f: is the number of the last file to analyse
    init_f = str2double(files_time(iter)); end_f = str2double(files_time(iter+1));
    Legend{iter} = string(strcat(num2str(Fhora(init_f)),{' - '},num2str(Fhora((end_f)))));
end

for profile_index = 1:2:length(v)
    
    init_f = str2double(files_time(profile_index)); end_f = str2double(files_time(profile_index+1));
    profile = mean(delta_v(:,init_f:end_f), 2);
    
    if quantity_index == 1
        profile_for_plot = profile; label_x = 'Volume depolarization ratio'; title_variable = '\delta^v';
    elseif quantity_index == 2
        %%%%%%%%%%%%%%Particle depolarization ratio obtention%%%%%%%%%%%%%%%%
        %%%YOU HAVE TO RUN THE KFS CODE BEFORE RUNING THIS SECTION, SINCE VALUE%%%
        % beta_aer_CH0 IS CALCULATED BY KFS CODE.

        BR2 =  (abs(mean(beta_aer_CH0, 2)) + beta_mol(1:1700)) ./ beta_mol(1:1700);
        BR2(BR2 < 1.1) = nan;
        delta_m = 0.003656;
        delta_p = ((BR2 .* delta_v(1:1700, :) * (delta_m + 1)) - (delta_m .* (delta_v(1:1700, :) + 1))) ./ (BR2 * (delta_m + 1) - (delta_v(1:1700, :) + 1));
        delta_p = profile;
        profile_for_plot = profile; label_x = 'Particle depolarization ratio'; title_variable = '\delta^p';
    end

    if col_n <= n
        plot_profile = plot(profile_for_plot, R, 'LineWidth', 0.8, 'Color', color_list(col_n) ,'DisplayName','cos'); hold on
        col_n = col_n + 1;
    end

    ylim([0 R(266)]);
    legend(Legend)
end

xlabel(label_x, 'FontSize', 21); ylabel('Altitude a.g.l [m]','FontSize',21);

title(strcat({' '},title_variable,' - \lambda = ', {' '}, wavelength, ' nm -',datestr(date), ' - ',{' '},...
    start_hour,' to ',{' '},end_hour,' UTC-5 - Medellín - Colombia'), 'FontSize', 22)


