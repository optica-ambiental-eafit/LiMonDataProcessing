%% This function aims to calculate the particle and volume depolarization ratio from calibration data
% Dark current of the calibration day readinf

%% Data reading
day = 10;
month = 10;
year = 2022;

%format long;

root_folder = 'C:\\Users\\paguirrea\\Desktop\\Práctica Pablo 2022-2\\Códigos MATLAB editados por Pablo\\Datos para procesamiento LIDAR 2022-2_practica\\%d\\%02d\\%02d';
path_lidar = sprintf(root_folder, year, month, day);        % in root_folder prints year,month,day as a format ( {}.format python )
altitude = 0:3.75:61318.75;
altitude = altitude';

%% Calibration profile

trigger_delay_bins = 28;
% dark_current_path = strcat(path_lidar,'\Calib\DC');
dark_current_path = strcat(path_lidar,'\Calib\medida 2\DC');
dark_current = open_files(dark_current_path);
dark_current = mean(dark_current, 2);
size(dark_current)
dark_current(1:trigger_delay_bins, :, :) = [];
size(dark_current)

calib_P45_path = strcat(path_lidar,'\Calib\medida 2\P45');
calib_P45 = open_files(calib_P45_path);
calib_P45 = mean(calib_P45, 2);
calib_P45(1:trigger_delay_bins, :, :) = [];
calib_P45(:,:,1) = abs(calib_P45(:,:,1) - dark_current(:,:,1));
calib_P45(:,:,2) = abs(calib_P45(:,:,2) - dark_current(:,:,2));
% 
calib_M45_path = strcat(path_lidar,'\Calib\medida 2\M45');
calib_M45 = open_files(calib_M45_path);
calib_M45 = mean(calib_M45, 2);
calib_M45(1:trigger_delay_bins, :, :) = [];
calib_M45(:,:,1) = abs(calib_M45(:,:,1) - dark_current(:,:,1));
calib_M45(:,:,2) = abs(calib_M45(:,:,2) - dark_current(:,:,2));
% 
gain_ratio_P45 = calib_P45(:, :, 2) ./ calib_P45(:, :, 1);
gain_ratio_M45 = calib_M45(:, :, 2) ./ calib_M45(:, :, 1);
gain_ratio_M45(gain_ratio_M45 > 10) = mean(gain_ratio_M45);
gain_ratio_P45(gain_ratio_P45 > 1.8) = mean(gain_ratio_P45(1:266));
gain_ratio_M45(570:610) = mean(gain_ratio_M45);
% 
gain_ratio_M45 = smooth(gain_ratio_M45, 0.0009,'loess');
% 
delta90_gain_ratio = sqrt(gain_ratio_M45 .* gain_ratio_P45);

%% Calibration profile plotting

depol_calib = figure('Color','white');

% gain_ratio_M45(570:610) = nan;

GR_P45_plot = plot(gain_ratio_P45(1:2133), altitude(1:2133),'LineWidth', 0.8, 'Color', 'k');
hold on
GR_M45_plot = plot(gain_ratio_M45(1:2133), altitude(1:2133), 'LineWidth', 0.8, 'Color', 'b');
GR_delta90_plot = plot(delta90_gain_ratio(1:2133), altitude(1:2133), 'LineWidth', 1, 'Color', 'r');

legend('\eta^*(+45)', '\eta^*(-45)', '\eta_{\Delta 90}');
xlim([0 10])
xticks(0:2:10)

ax_1 = gca;
ax_1.FontSize = 14;
xlabel('Gain ratio', 'FontSize', 18)
ylabel('Altitude a.g.l [m]', 'FontSize', 18)
title('Depolarization calibration,' - \lambda = ', {' '}, wavelength, ' nm' -datestr(date), ' - ',{' '},...
    start_hour,' to ',{' '},end_hour,' UTC-5 - Medellín - Colombia'), 'FontSize', 22)

title(strcat('Depolarization calibration', ' - 12 April 2022 - Medellín - LiMon'), 'FontSize', 18)

%% Raw signal lecture

day = 11; month = 04; year = 2022;
root_folder = 'C:\\Users\\paguirrea\\Desktop\\Práctica Pablo 2022-2\\Códigos MATLAB editados por Pablo\\Datos para procesamiento LIDAR 2022-2_practica\\%d\\%02d\\%02d';
path_lidar = sprintf(root_folder, year, month, day);        % in root_folder prints year,month,day as a format ( {}.format python )

raw_signal_path = strcat(path_lidar,'\RS');              % strcat -> stands for string concatenation
raw_signal = open_files(raw_signal_path);              % open_files is a function in .m format saved in the current directory

tmp = dir(raw_signal_path);                                                     % dir lista los archivos en el directorio
tmp=tmp(~ismember({tmp.name},{'.','..','temp.dat.txt'}));            % dir por defecto lista dos archivos vacíos al inicio llamados . y .., en esta línea se eliminan

file_names_RS(1 : length(tmp)) = {""}; %#ok<STRSCALR>       % una vez listados los archivos, almacena los nombres en celdas

% Obtener los nombres de los archivos permite identificar que se haya abierto la carpeta correcta:
for file = 1 : length(tmp)
    file_names_RS(file) = cellstr(strcat(tmp(file).folder, '\', tmp(file).name));   % Al string de dirección de directorio le concatena el string del nombre, o sea, tmp(file).name
end                                                                                                          % cellstr lo que hace es guardar lista de strings como celdas

%% Volume depolarization ratio obtention
signal_CH0 = raw_signal(trigger_delay_bins+1:end,:,1); signal_CH1 = raw_signal(trigger_delay_bins+1:end,:,2);

app_delta_v = (1./ delta90_gain_ratio(:)) .* (signal_CH1 ./ signal_CH0);
app_delta_v2 = (delta90_gain_ratio(:)) .* (signal_CH1 ./ signal_CH0);

GT = 1;
GR = 1;
HT = 1;
HR = -1;

delta_v = ((app_delta_v * (GT + HT)) - (GR + HR)) ./ ((GR - HR) - (app_delta_v * (GT - HT)));

%% Aquí preguntar por perfiles
n = input('Please insert how many profiles do you want to retrieve: ')
options = cell(1,2*n);
v = [1:n]; v = sort([v,v]);     % Vector for saving profiles quantities

% Time interval definition

num_of_files = size(file_names_RS,2);
Fhora = zeros(1,size(file_names_RS,2));
for file_index = 1:num_of_files
    Fhora(1,file_index) = str2num(file_names_RS{file_index}(end-12:end-8));                             
end

local_time = Fhora;         % Vector en el que se almacenan las horas
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

dlgtitle = 'Input';     
dims = [1 50];      % Width and height of the box
files_time = inputdlg(options,dlgtitle,dims);

%%  %   %   %

% delta_v_nube = mean(delta_v(:, :), 2);
% delta_v_nube(1:10, :, :) = [];
% delta_v_perfil1 = mean(delta_v(:, 12:24), 2);
% delta_v_perfil1(1:10, :, :) = [];
% delta_v_perfil2 = mean(delta_v(:, 12:25), 2);
% delta_v_perfil2(1:10, :, :) = [];

%%
user_choice = menu('Choose the optical product profile you want to display: ', 'Volume depolarization ratio','Particle depolarization ratio');

switch (user_choice)
    case 1
        quantity_index = 1;
    case 2
        quantity_index = 2;    
end

f = figure('Color','white');
color_list = ['r','b','k','m','c']; col_n = 1;
R = 1:3.75:(3.75*size(delta_v));

Legend = cell(n,1);
for iter = 1:n
    init_f = str2double(files_time(iter)); end_f = str2double(files_time(iter+1));
    Legend{iter} = string(strcat(num2str(Fhora(init_f)),{' - '},num2str(Fhora((end_f)))));
end

for profile_index = 1:2:length(v)
    
    init_f = str2double(files_time(profile_index)); end_f = str2double(files_time(profile_index+1));
    profile = mean(delta_v(:,init_f:end_f), 2);
    profile = smooth(profile, 0.01,'loess');
    
    if quantity_index == 1
        profile_for_plot = profile; label_x = 'Volume depolarization ratio'; title_variable = '\delta^v';
    elseif quantity_index == 2
        profile_for_plot = profile; label_x = 'Particle depolarization ratio'; title_variable = '\delta^p';
    end
    if col_n <= n
        plot_profile = plot(profile_for_plot, R, 'LineWidth', 0.8, 'Color', color_list(col_n) ,'DisplayName','cos'); hold on
        col_n = col_n + 1;
    end

    ylim([0 max(R(1:1700))]);
    legend(Legend)
end

xlabel(label_x, 'FontSize', 21); ylabel('Altitude a.g.l [m]','FontSize',21);

title(strcat({' '},title_variable,' - \lambda = ', {' '}, wavelength, ' nm -',datestr(date), ' - ',{' '},...
    start_hour,' to ',{' '},end_hour,' UTC-5 - Medellín - Colombia'), 'FontSize', 22)
%% Volume depolarization ratio plotting

fig_deltav = figure('Color','white');

R = 1:3.75:3.75*(size(delta_v,1)); R = R';
plot(delta_v_nube, R, 'LineWidth', 1, 'Color', 'b')
hold on
plot(delta_v_perfil1(1:25), R(1:25), 'LineWidth', 1, 'Color', 'k'); hold on
plot(delta_v_perfil2(1:26), R(1:26), 'LineWidth', 1, 'Color', 'r')
ylim([0 1000])
xlim([0.03 0.1])
xtickformat('%.2f')

ax = gca;
ax.FontSize = 14;
ylabel('Altitude a.g.l [m]', 'FontSize', 20)
xlabel('Volume depolarization ratio', 'FontSize', 20)
title('\delta^v - \lambda = 532 nm - 13 April 2022', '15:54 to 21:31 UTC - Medellín - LiMon',...
    'FontSize', 22)
legend('15:54 - 17:00', '17:01 - 18:30', '18:31 - 21:31', 'FontSize', 16, 'Location', 'Southeast')

%% Particle depolarization ratio obtention

BR2 =  (abs(mean(beta_aer_CH0, 2)) + beta_mol(1:1700)) ./ beta_mol(1:1700);
BR2(BR2 < 1.1) = nan;
% delta_v = mean(delta_v, 2);
delta_m = 0.003656;
% delta_p = delta_v - delta_m;
delta_p = ((BR2 .* delta_v(1:1700, :) * (delta_m + 1)) - (delta_m .* (delta_v(1:1700, :) + 1))) ./ (BR2 * (delta_m + 1) - (delta_v(1:1700, :) + 1));
% delta_p = mean(delta_p, 2);

delta_p_nube = mean(delta_p(:, 1:133), 2);
delta_p_nube(1:10, :, :) = [];
delta_p_perfil1 = mean(delta_p(:, 134:312), 2);
delta_p_perfil1(1:10, :, :) = [];
delta_p_perfil2 = mean(delta_p(:, 313:end), 2);
delta_p_perfil2(1:10, :, :) = [];

%% Particle depolarization ratio plotting

fig_deltap = figure('Color','white');

plot(delta_p_nube(1:267), R(1:267), 'LineWidth', 1, 'Color', 'b')
hold on
plot(delta_p_perfil1(1:267), R(1:267), 'LineWidth', 1, 'Color', 'k')
plot(delta_p_perfil2(1:267), R(1:267), 'LineWidth', 1, 'Color', 'r')
ylim([0 1000])
xlim([0.04 0.16])

ax = gca;
ax.FontSize = 14;
ylabel('Altitude a.g.l [m]', 'FontSize', 20)
xlabel('Particle depolarization ratio', 'FontSize', 20)
title('\delta^p - \lambda = 532 nm - 13 April 2022', '15:54 to 21:31 UTC - Medellín - LiMon',...
    'FontSize', 22)
legend('15:54 - 17:00', '17:01 - 18:00', '18:01 - 21:31', 'FontSize', 16, 'Location', 'Southeast')

