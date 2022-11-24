clear
clearvars
close all
clc
warning('off')

%% Root folder definition

day = 14;
month = 07;
year = 2022;

%format long;

root_folder = 'C:\\Users\\paguirrea\\Desktop\\Práctica Pablo 2022-2\\Códigos MATLAB editados por Pablo\\Datos para procesamiento LIDAR 2022-2_practica\\%d\\%02d\\%02d';
path_lidar = sprintf(root_folder, year, month, day);        % in root_folder prints year,month,day as a format ( {}.format python )


%% Raw signal (RS) directory reading and raw_signal creation

%flag = 1;
trigger_delay_bins = 34;
raw_signal_path = strcat(path_lidar,'\RS');              % strcat -> stands for string concatenation
raw_signal = open_files(raw_signal_path);              % open_files is a function in .m format saved in the current directory

tmp = dir(raw_signal_path);                                                     % dir lista los archivos en el directorio
tmp=tmp(~ismember({tmp.name},{'.','..','temp.dat.txt'}));            % dir por defecto lista dos archivos vacíos al inicio llamados . y .., en esta línea se eliminan

file_names_RS(1 : length(tmp)) = {""}; %#ok<STRSCALR>       % una vez listados los archivos, almacena los nombres en celdas

% Obtener los nombres de los archivos permite identificar que se haya abierto la carpeta correcta:
for file = 1 : length(tmp)
    file_names_RS(file) = cellstr(strcat(tmp(file).folder, '\', tmp(file).name));   % Al string de dirección de directorio le concatena el string del nombre, o sea, tmp(file).name
end                                                                                                          % cellstr lo que hace es guardar lista de strings como celdas

num_of_files = size(raw_signal,2);
raw_signal = raw_signal(:,1:num_of_files,1);

%% Dark current (DC) directory reading and dark_current/DC creation
% During the measurement campaign no DC was measured. This data is taken
% from april 2022.

dark_current_path = strcat(path_lidar,'\DC');
dark_current = open_files(dark_current_path);                               % Aquí se abren todos los archivos contenidos en la ruta...\04\13\DC y sus datos quedan guardados en una matriz 2-dim. En una capa pol p, en la otra pol s.

DC = mean(dark_current,2);                                                         % Devuelve en un vector columna la media de cada fila

tmp = dir(dark_current_path);
tmp=tmp(~ismember({tmp.name},{'.','..','temp.dat.txt'}));

file_names_DC(1 : length(tmp)) = {""}; %#ok<STRSCALR>

% Executes if the dark_current_path does not exist as a dir value.
% exist(path,'dir') returns a 7 and ~exist returns a 0 as boolean
if ~exist(dark_current_path, 'dir')     
    dark_current_path = 'C:\Users\paguirrea\Desktop\Práctica Pablo 2022-2\Códigos MATLAB editados por Pablo\Datos para procesamiento LIDAR 2022-2_practica\DC';
    tmp = dir(dark_current_path);
end

% Obtener los nombres de los archivos permite identificar que se haya abierto la carpeta correcta:
for file = 1 : length(tmp)                                                                                % originalmente el ciclo arrancaba en 1, pero los file_names_DC{1} y {2} no contenían archivo para leer
    file_names_DC(file) = cellstr(strcat(tmp(file).folder, '\', tmp(file).name));       % Al string de dirección de directorio le concatena el string del nombre, o sea, tmp(file).name
end                                                                                                              % cellstr lo que hace es guardar lista de strings como celdas



%% Signal matrix creation 

tic 

signal = zeros(size(raw_signal(trigger_delay_bins:end, :, :)));         % Takes from 34 to the end because the first 35 data are trigger delay
signal_filt = signal;

for channel = 1 : size(raw_signal, 3)
    for file_index = 1 : size(raw_signal, 2)
        signal(:, file_index, channel) = raw_signal(trigger_delay_bins:end, file_index, channel) - DC(trigger_delay_bins:end,1,1);
    end
end

signal = abs(signal);
%signal = signal(:,323:519,1);
num_of_files = size(signal,2);

toc

%% Range Corrected Signal matrix calculation

valid_data_size = trigger_delay_bins:size(signal,1);
height = valid_data_size.* 3.75;                                % Height Column
height = height';   height = height(1:num_of_files);

%Range Corrected Signal
RCS = zeros(size(signal));   
tic

for channel = 1 : size(raw_signal, 3)
    RCS(:, :, channel) = signal(:, :, channel) .* height' .* height'; 
end

%% Creation of a vector that contains the UTC-5 time from the file names

Fhora = zeros(1,size(signal,2));
for file_index = 1:num_of_files
    Fhora(1,file_index) = str2num(file_names_RS{file_index}(end-12:end-6));  
    %local_time(:, file_index) = daGtenum([Fhora(1:2) ':' Fhora(4:5)], 'HH:MM');
end
local_time = Fhora;         % Vector en el que se almacenan las horas

start_hour = num2str(min(local_time)); 
end_hour = num2str(max(local_time));

%%

wavelength = 532;
theta = 24; 
distance = height.*cos(theta);
height_sup = abs(height.*sin(theta));


year_v=ones(1,length(Fhora))*year;m=ones(1,length(Fhora))*month; d=ones(1,length(Fhora))*day; s=zeros(1,length(Fhora));

h = fix(Fhora); h = h';
M = zeros(size(h,1),1);

for i = 1:length(h)
    try
    aux = num2str(mod(Fhora(1,i),2)); 
    M(i,1) = str2num(aux(3:4)); s(i,1) = str2num(aux(5:6));
    catch
        aux(4) = '0';
    end
end

n= datetime(2022,7,14,1:200,1:200,0);

for i=1:length(h)
%     n= datetime(year_v(1,1):year_v(1,end),m(1,1):m(1,end),d(1,1):d(1,end),h(1,1):h(end,1),M(1,1):M(end,1),s(1,1):s(1,end));
     n(1,i) = datetime(year_v(1,i),m(1,i),d(1,i),h(i,1),M(i,1),s(1,i));
end

y = n; y = y';

figure

for dist = 1:size(height,1)
    x = distance(dist)*ones(size(distance,1),1);
    z = height_sup(dist)*ones(size(height,1),1);
    scatter3(x,y,z, 50 , RCS(dist,1:num_of_files),'filled'); 
    colorbar; hold on;
    set(gca,'ColorScale','log')
end


% Title variables
theta = num2str(theta);
wavelength = num2str(wavelength);
date = datetime(year, month, day);
date.Format = 'dd MMM yyyy';

xlim([0 max(x)]);

ylim([datetime(2022,7,14,15,30,0) datetime(2022,7,14,19,0,0)])
zlim([0 max(z)])
axis xy; 
xlabel('Distance [m]','FontSize',20); ylabel('Time UTC-5','FontSize',20); zlabel('Height [m]','FontSize',20); theta = '66°';
title(strcat('Spatiotemporal reconstruction of RCS - \lambda = ', {' '}, wavelength, ' nm -', '\theta = ',{' '},theta, datestr(date),'- UTF-5 - Medellín - Colombia'), 'FontSize', 20)
colormap jet