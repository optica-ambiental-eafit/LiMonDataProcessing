%% Quicklook obtention code:
%
% This program has been developed by Manuela Hoyos-Restrepo based on the
% code developed by Elena Montilla-Rosero and edited by Pablo Aguirre-Álvarez. It will be used for obtaining signal profiles and quicklook.
% ----------------------------------------------------------------------------------------------------------
% Last edition on: 06-12-2022 by Pablo Aguirre-Álvarez.
% ----------------------------------------------------------------------------------------------------------
% -------------------------------------------- Main variables: ---------------------------------------------
% # raw_signal = 16380 bins x number of files(2 per minute) x 2 (channel 0 and channel 1) matrix
% # dark_current = 16380 bins x number of files(2 per minute) x 2 (channel 0 and channel 1) matrix
% 
% ----------------------------------------------------------------------------------------------------------

%% Deletion of old variables in workspace, console and closure of active figures

clear
clearvars
clc
warning('off')
close all

%% Root folder definition

% Date of measurements to process:
day = 27;
month = 09;
year = 2022;

%root_folder = 'C:\\Users\\paguirrea\\Desktop\\Práctica Pablo 2022-2\\Códigos MATLAB editados por Pablo\\Datos para procesamiento LIDAR 2022-2_practica\\%d\\%02d\\%02d';
root_folder = 'C:\\Users\\usuario\\OneDrive - Universidad EAFIT\\Códigos LIDAR pablo\\Datos para procesamiento\\%d\\%02d\\%02d';    % ALWAYS use double backslash ( \\ )
path_lidar = sprintf(root_folder, year, month, day);        % in root_folder prints year, month, day as a format ( see {}.format python )

%% Raw signal (RS) directory reading and raw_signal creation

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

%% Dark current filtered signal  (DC_filtered creation)
% Here the spurious DC data are deleted applying the interquartile range criterion.

% Filtered dark current is saved in DC_filt variable.
v = isoutlier(DC,'quartiles');
DC_filt = DC;

% If a DC data is spurius, then assign it the mean DC value:
for bin_index=1:size(DC,1)
    for channel_index=1:size(DC,3)
        if v(bin_index,1,channel_index)==1
           DC_filt(bin_index,1,channel_index) = mean(DC(:,:,channel_index));
        end             
    end
end

%% Data initialization

LRaer = 61;                                                             % LR for aerosols in Medellin = 61 [sr] (M.Hoyos, 2022)
num_of_files = size(raw_signal, 2);                           % Number of RS files
data_size = 2000;
max_height = 20000;                                              % Maximum height [m]

R0 = floor(6375/3.75);                                             % Reference height in bins (See Rayleigh fit)
data_range = 1:R0;                                                 % Height of measurements of interest
local_time = zeros(1, size(raw_signal, 2));                 % Creation of vector for saving the time interval of performed measurements

trigger_delay_bins = 28;                                          % (M.Hoyos ,2022)
height = linspace(0,5000,size(raw_signal,1)-trigger_delay_bins+1);      % Creation of vector from zero to last raw_signal data bin. Trigger delay correction is applied.
height = height';                                                    % Transposed height vector in order to get a column

m = 1;                                                                   % Polarization component. Choose 1 for p or 2 for s.

%% Signal matrix creation and DC & DC_filtered correction

signal = zeros(size(raw_signal(trigger_delay_bins:end, :, :)));         % Takes from 28 to the end because the first 28 data are trigger delay
signal_filt = signal;                                                                      % Creates a copy of signal for replacing its values for the signal with the DC filtered correction

% Dark current correction:
for channel = 1 : size(raw_signal, 3)
    for file_index = 1 : size(raw_signal, 2)
        signal(:, file_index, channel) = raw_signal(trigger_delay_bins:end, file_index, channel) - DC(trigger_delay_bins:end, 1, channel);  
        signal_filt(:,file_index,channel) = raw_signal(trigger_delay_bins:end, file_index, channel) - DC_filt(trigger_delay_bins:end, 1, channel);
    end
end

signal = abs(signal); signal_filt = abs(signal_filt);    % abs = absolute value

%% Background correction
% Only correct background if DC did not substracted all your signal

signal_BG = abs(signal - mean(signal(end-12000:end)));                      % Takes the average of data associated with heigths greater than 1200 m and substracts it to the signal
signal_filt_BG = abs(signal_filt - mean(signal_filt(end-12000:end)));       % Takes the average of data associated with heigths greater than 1200 m and substracts it to the signal with DC_filt
signal(signal<0) = nan; signal_filt(signal_filt<0) = nan;                         % If maybe a negative value is retrieved, then it is taken as nan (not a number)

%% Range Corrected Signal matrix calculation

valid_data_size = trigger_delay_bins : length(signal) + trigger_delay_bins-1;
height = valid_data_size * 3.75;                                % Height Column
height = height';

%Range Corrected Signal matrices creation with null elements:
RCS = zeros(size(signal));    RCS_filt = zeros(size(signal_filt));    RCS_BG = zeros(size(signal_BG));    RCS_filt_BG = zeros(size(signal_filt_BG));

% Range Corrected Signal matrix is filled:
for channel_index = 1 : size(raw_signal, 3) % channel_index is determines  1 = p or 2 = s polarization states
    RCS(:, :, channel_index) = signal(:, :, channel_index) .* height .* height; 
    % RCS variable can be changed for RCS_filt, RCS_BG, RCS_filt_BG at the user's discretion
end

%% Smoothing of range corrected signal
% The filtered applied is 'rloess'. See also 'movmedian', 'gaussian', 'lowess' or 'rlowess':
for channel_index=1:2       
    RCS(2000:end,channel_index) = smooth(RCS(2000:end,channel_index),0.006,'rloess');
    % RCS variable can be changed for RCS_filt, RCS_BG, RCS_filt_BG at the user's discretion
end

%% Creation of a vector that contains the UTC-5 time from the file names
Fhora = zeros(1,size(file_names_RS,2));                                                         % Creation of empty vector for saving time interval
for file_index = 1:num_of_files
    Fhora(1,file_index) = str2num(file_names_RS{file_index}(end-12:end-8));    % Captures the time from the RS file name                           
    %local_time(:, file_index) = daGtenum([Fhora(1:2) ':' Fhora(4:5)], 'HH:MM');
end
local_time_formato = datestr(hours(Fhora),'HH:MM');
local_time = Fhora;         

%% Signal profile obtention
% A menu is displayed so the user can choose the profiles to analize. The plot titles are generated automatically by the function profile_plots.m.

% Menu creation and selection of the titles for the figures:
user_choice = menu('Choose the profile you want to display: ', 'Raw','Raw-DC','Raw-DC-Background', 'Dark current profile','All in one figure','Dark current filtered profile');
profile_titles = {'Raw Signal','Raw signal profile - DC','Raw signal profile - DC - Background','Dark Current'};
height = linspace(0,60000,size(raw_signal,1)-trigger_delay_bins+1); height = height';
max_time_data = size(raw_signal,2);                      % Time of the last measured data so the program knows the final time for integration of the profile

switch (user_choice)
    % Cases 1 to 4 allow to show each profile individually. Case 5 shows all the profiles as subplots in one figure. Case 6 shows DC filtered signal.
    % Index i = integer number determines the signal that is going to be ploted and therefore, which title has to be chosen from 'profile_titles' variable.
    case 1                                      % Raw signal profile
        i = 1;
        signal_profile_fig = figure('Color','white');
        profile_values_0 = mean(raw_signal(trigger_delay_bins:end,1:max_time_data,1),2); profile_values_1 = mean(raw_signal(trigger_delay_bins:end,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)     % profile_plots.m is called
    case 2                                     % Raw signal - DC profile
        i = 3;
        signal_profile_fig = figure('Color','white');
        profile_values_0 = mean(signal(:,1:max_time_data,1),2); profile_values_1 = mean(signal(:,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)     % profile_plots.m is called
    case 3                                     % Raw signal -  DC - Background profile
        i = 3;
        signal_profile_fig = figure('Color','white');
        profile_values_0 = mean(signal_BG(:,1:max_time_data,1),2); profile_values_1 = mean(signal_BG(:,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)     % profile_plots.m is called
    case 4                                     % Dark current profile
        i = 4;
        signal_profile_fig = figure('Color','white');
        profile_values_0 = DC(trigger_delay_bins:end, 1, 1); profile_values_1 = DC(trigger_delay_bins:end, 1, 2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)     % profile_plots.m is called
   
    case 5                             % All the profiles as subplots in one figure:
        subplot(2,2,1)              %%%
        i = 1;
        profile_values_0 = mean(raw_signal(trigger_delay_bins:end,1:max_time_data,1),2); profile_values_1 = mean(raw_signal(trigger_delay_bins:end,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)      % profile_plots.m is called 
        subplot(2,2,2)              %%%
        i = 2;
        profile_values_0 = mean(signal(:,1:max_time_data,1),2); profile_values_1 = mean(signal(:,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)     % profile_plots.m is called
        subplot(2,2,3)              %%%
        i = 3;
        profile_values_0 = mean(signal_BG(:,1:max_time_data,1),2); profile_values_1 = mean(signal_BG(:,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)     % profile_plots.m is called
        subplot(2,2,4)              %%%
        i = 4;
        profile_values_0 = DC(trigger_delay_bins:end, 1, 1); profile_values_1 = DC(trigger_delay_bins:end, 1, 2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)     % profile_plots.m is called
     
    case 6
        i = 4;
        profile_values_0 = DC_filt(trigger_delay_bins:end, 1, 1); profile_values_1 = DC_filt(trigger_delay_bins:end, 1, 2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)     % profile_plots.m is called
   
end

%% Quicklook figure
% Here the Range Corrected Signal (RCS) is ploted as an image with scaled colors.

for channel_index= 1:2
    
    quicklook = figure('Color','white', 'units', 'normalized', 'outerposition', [0 0 1 1]);     % Figure creation
    imagesc(local_time, height', RCS(:,:,channel_index));                                               % Imaged with scaled color creation
    % Figure basic configuration of axis, labels, colormap, etc:
    colormap jet; colorbar;
    caxis([0.1e03 3e06]); xlim([min(local_time) max(local_time)]); ylim([min(height) 5000]); axis xy; 
    %set(gca,'ColorScale','log')                                                                                    % Uncomment for logarithmic color scale
    xlabel('Time UTC-5', 'FontSize', 20); ylabel('Altitude a.g.l [m]', 'FontSize', 20);
    
    % Title configuration (date is automatically set):
    date = datetime(year, month, day);
    date.Format = 'dd MMM yyyy';
    wavelength = '532';
    if channel_index == 1
        pol_state = 'p';
    else
        pol_state = 's';
    end
    title(strcat('RCS - \lambda = ', {' '}, wavelength, ' nm -',pol_state,  {' '}, datestr(date), ' - Medellín - Colombia'), 'FontSize', 22)
end