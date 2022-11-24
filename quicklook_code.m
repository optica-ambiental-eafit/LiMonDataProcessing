%% This program has been developed by Manuela Hoyos-Restrepo based on the
% code developed by Elena Montilla-Rosero and edited by Pablo Aguirre-Álvarez.
% It will be used for obtaining signal profiles and quicklooks
%%

clear
clearvars
clc
warning('off')
close all

%% Root folder definition

day = 27;
month = 09;
year = 2022;

%format long;

%root_folder = 'C:\\Users\\paguirrea\\Desktop\\Práctica Pablo 2022-2\\Códigos MATLAB editados por Pablo\\Datos para procesamiento LIDAR 2022-2_practica\\%d\\%02d\\%02d';
root_folder = 'C:\\Users\\usuario\\OneDrive - Universidad EAFIT\\Códigos LIDAR pablo\\Datos para procesamiento\\%d\\%02d\\%02d';
path_lidar = sprintf(root_folder, year, month, day);        % in root_folder prints year,month,day as a format ( {}.format python )


%% Raw signal (RS) directory reading and raw_signal creation

raw_signal_path = strcat(path_lidar,'\RS');              % strcat -> stands for string concatenation
if exist(raw_signal_path)
    raw_signal = open_files(raw_signal_path);              % open_files is a function in .m format saved in the current directory
end

tmp = dir(raw_signal_path);                                                     % dir lista los archivos en el directorio
tmp=tmp(~ismember({tmp.name},{'.','..','temp.dat.txt'}));            % dir por defecto lista dos archivos vacíos al inicio llamados . y .., en esta línea se eliminan

file_names_RS(1 : length(tmp)) = {""}; %#ok<STRSCALR>       % una vez listados los archivos, almacena los nombres en celdas

% Obtener los nombres de los archivos permite identificar que se haya abierto la carpeta correcta:
for file = 1 : length(tmp)
    file_names_RS(file) = cellstr(strcat(tmp(file).folder, '\', tmp(file).name));   % Al string de dirección de directorio le concatena el string del nombre, o sea, tmp(file).name
end                                                                                                          % cellstr lo que hace es guardar lista de strings como celdas


%% Dark current (DC) directory reading and dark_current/DC creation

dark_current_path = strcat(path_lidar,'\DC');
if exist(dark_current_path)
    dark_current = open_files(dark_current_path);                               % Aquí se abren todos los archivos contenidos en la ruta...\04\13\DC y sus datos quedan guardados en una matriz 2-dim. En una capa pol p, en la otra pol s.
end

DC = mean(dark_current,2);                                                         % Devuelve en un vector columna la media de cada fila

tmp = dir(dark_current_path);
tmp=tmp(~ismember({tmp.name},{'.','..','temp.dat.txt'}));

file_names_DC(1 : length(tmp)) = {""}; %#ok<STRSCALR>

% Executes if the dark_current_path does not exist as a dir value.
% exist(path,'dir') returns a 7 and ~exist returns a 0 as boolean
if ~exist(dark_current_path, 'dir')     
    %dark_current_path = 'C:\Users\paguirrea\Desktop\Práctica Pablo 2022-2\Códigos MATLAB editados por Pablo\Datos para procesamiento LIDAR 2022-2_practica\DC';
    
    tmp = dir(dark_current_path);
end

% Obtener los nombres de los archivos permite identificar que se haya abierto la carpeta correcta:
for file = 1 : length(tmp)                                                                                % originalmente el ciclo arrancaba en 1, pero los file_names_DC{1} y {2} no contenían archivo para leer
    file_names_DC(file) = cellstr(strcat(tmp(file).folder, '\', tmp(file).name));       % Al string de dirección de directorio le concatena el string del nombre, o sea, tmp(file).name
end                                                                                                              % cellstr lo que hace es guardar lista de strings como celdas

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

%% Data initialization

% ¿cuál es el argumento para tomar estas constantes?
LRaer = 61; %(20 en Natal)

num_of_files = size(raw_signal, 2);
data_size = 2000;
max_height = 20000; %[m]

R0 = floor(7200/3.75);
data_range = 1:R0;
local_time = zeros(1, size(raw_signal, 2));

trigger_delay_bins = 34;
height = linspace(0,5000,size(raw_signal,1)-trigger_delay_bins+1);
height = height';


% Choose 1 for p or 2 for s
m = 1;

%% Signal matrix creation and DC & DC_filtered correction

tic 

signal = zeros(size(raw_signal(trigger_delay_bins:end, :, :)));         % Takes from 34 to the end because the first 35 data are trigger delay
signal_filt = signal;

for channel = 1 : size(raw_signal, 3)
    for file_index = 1 : size(raw_signal, 2)
        signal(:, file_index, channel) = raw_signal(trigger_delay_bins:end, file_index, channel) - DC(trigger_delay_bins:end, 1, channel);  % Se omiten 34 elementos iniciales pues son trigger delay
        signal_filt(:,file_index,channel) = raw_signal(trigger_delay_bins:end, file_index, channel) - DC_filt(trigger_delay_bins:end, 1, channel);
    end
end

signal = abs(signal);
toc
%% Background correction

signal_BG = abs(signal - mean(signal(end-12000:end))); % This sentence will be applied if there is not any darkcurent or background information
signal_filt_BG = abs(signal_filt - mean(signal_filt(end-12000:end)));
signal(signal<0) = nan; signal_filt(signal_filt<0) = nan;

%% Range Corrected Signal matrix calculation

valid_data_size = 34 : length(signal) + 33;
height = valid_data_size * 3.75;                                % Height Column
height = height';

%Range Corrected Signal
RCS = zeros(size(signal));    RCS_filt = zeros(size(signal_filt));    RCS_BG = zeros(size(signal_BG));    RCS_filt_BG = zeros(size(signal_filt_BG));

tic

for channel = 1 : size(raw_signal, 3)
    RCS(:, :, channel) = signal(:, :, channel) .* height .* height; 
    RCS_filt(:, :, channel) = signal_filt(:, :, channel) .* height .* height;
    RCS_BG(:, :, channel) = signal_BG(:, :, channel) .* height .* height;
    RCS_filt_BG(:, :, channel) = signal_filt_BG(:, :, channel) .* height .* height;
end

%% Smoothing of range corrected signal
for channel_index=1:2
    RCS(2000:end,channel_index) = smooth(RCS(2000:end,channel_index),0.006,'rloess');
    %RCS_filt(2000:end,channel_index) = smooth(RCS_filt(2000:end,channel_index),0.006,'rloess');
    %RCS_BG(2000:end,channel_index) = smooth(RCS_BG(2000:end,channel_index),0.006,'rloess');
    %RCS_filt_BG(2000:end,channel_index) = smooth(RCS_filt_BG(2000:end,channel_index),0.006,'rloess');
end
%RCS = RCS(1:2000);
toc 
%% Creation of a vector that contains the UTC-5 time from the file names

Fhora = zeros(1,size(file_names_RS,2));
for file_index = 1:num_of_files
    Fhora(1,file_index) = str2num(file_names_RS{file_index}(end-12:end-8));                             
    %local_time(:, file_index) = daGtenum([Fhora(1:2) ':' Fhora(4:5)], 'HH:MM');
end
%local_time_formato = datestr(hours(Fhora),'HH:MM');

local_time = Fhora;         % Vector en el que se almacenan las horas

%% Signal profile obtention

user_choice = menu('Choose the profile you want to display: ', 'Raw','Raw-DC','Raw-DC-Background', 'Dark current profile','All in one figure','Dark current filtered profile');
file_number = 400;
profile_titles = {'Raw Signal','Raw signal profile - DC','Raw signal profile - DC - Background','Dark Current'};
height = linspace(0,60000,size(raw_signal,1)-trigger_delay_bins+1); height = height';
max_time_data = size(raw_signal,2);

switch (user_choice)
    case 1                                      % Raw signal
        i = 1;
        signal_profile_fig = figure('Color','white');
        profile_values_0 = mean(raw_signal(trigger_delay_bins:end,1:max_time_data,1),2); profile_values_1 = mean(raw_signal(trigger_delay_bins:end,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)
    case 2                                     % Raw signal - DC
        i = 3;
        signal_profile_fig = figure('Color','white');
        profile_values_0 = mean(signal(:,1:max_time_data,1),2); profile_values_1 = mean(signal(:,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)
    case 3                                     % Raw signal -  DC - Background
        i = 3;
        signal_profile_fig = figure('Color','white');
        profile_values_0 = mean(signal_BG(:,1:max_time_data,1),2); profile_values_1 = mean(signal_BG(:,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)
    case 4                                     % Dark current profile
        i = 4;
        signal_profile_fig = figure('Color','white');
        profile_values_0 = DC(trigger_delay_bins:end, 1, 1); profile_values_1 = DC(trigger_delay_bins:end, 1, 2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)
        
    case 5
        subplot(2,2,1)              %%%
        i = 1;
        profile_values_0 = mean(raw_signal(trigger_delay_bins:end,1:max_time_data,1),2); profile_values_1 = mean(raw_signal(trigger_delay_bins:end,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)       
        subplot(2,2,2)              %%%
        i = 2;
        profile_values_0 = mean(signal(:,1:max_time_data,1),2); profile_values_1 = mean(signal(:,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)
        subplot(2,2,3)              %%%
        i = 3;
        profile_values_0 = mean(signal_BG(:,1:max_time_data,1),2); profile_values_1 = mean(signal_BG(:,1:max_time_data,2),2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)
        subplot(2,2,4)              %%%
        i = 4;
        profile_values_0 = DC(trigger_delay_bins:end, 1, 1); profile_values_1 = DC(trigger_delay_bins:end, 1, 2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)
     
    case 6
        i = 4;
        profile_values_0 = DC_filt(trigger_delay_bins:end, 1, 1); profile_values_1 = DC_filt(trigger_delay_bins:end, 1, 2);
        profile_plots(profile_values_0,profile_values_1,profile_titles,i,height,year,month,day)
   
end

%% Quicklook figure


for m= 1:2
    quicklook = figure('Color','white', 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    imagesc(local_time, height', RCS(:,:,m));  
    caxis([0.1e03 3e06]);
    colormap jet;
    xlim([min(local_time) max(local_time)])
    ylim([min(height) 5000])
    axis xy; 
    colorbar;
    %set(gca,'ColorScale','log')
    ylabel('Altitude a.g.l [m]', 'FontSize', 20)
    xlabel('Time UTC-5', 'FontSize', 20)
    

    date = datetime(year, month, day);
    date.Format = 'dd MMM yyyy';
    %wavelength = extractBetween(strData{1, 1}(12), 1, 3);
    wavelength = '532';
    if m == 1
        pol_state = 'p';
    else
        pol_state = 's';
    end

    title(strcat('RCS - \lambda = ', {' '}, wavelength, ' nm -',pol_state,  {' '}, datestr(date), ' - Medellín - Colombia'), 'FontSize', 22)
end