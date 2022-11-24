%% Standard Atmosphere data for molecular backscattering, Lidar Ratio and extinction calculation

% Meteorological data reading from standard atmosphere data file
%meteo_file = 'C:\Users\paguirrea\Desktop\Práctica Pablo 2022-2\Códigos MATLAB editados por Pablo\T-P prof Standard Atmosph.txt';
meteo_file = 'C:\Users\usuario\OneDrive - Universidad EAFIT\Códigos LIDAR pablo\T-P prof Standard Atmosph.txt';
meteo_file = dlmread(meteo_file, '\t', 1, 0);
mol_pressure = (meteo_file(:, 3)) / 100; % [hPa]
mol_height = meteo_file(:, 1); % [m]
mol_temperature = meteo_file(:, 2); % [K]

% Molecular backscatter coefficient at 532 nm (beta_mol_532)
% Wavelength in micrometers
[beta_mol_532, LR_mol] = molecular(mol_pressure, mol_temperature, 0.532);
%z = mol_height/1000;
% R_mol = ((0 : size(raw_signal(35:end, :, :), 1)) * 3.75)';
R_mol = ((1 : size(signal, 1)) * 3.75)';
%tau(1,1) = 0;

altitude_lidar = 1495;
% beta_mol = exp(interp1(mol_height, log(beta_mol_532), R_mol + altitude_lidar, 'linear', 'extrap'));
beta_mol = exp(interp1(mol_height, log(beta_mol_532), R_mol, 'linear', 'extrap'));
alpha_mol = LR_mol .* beta_mol;

%% Data initialization

%theta = 1;
LRaer = 61; %(20 en Natal)

% num_of_files = size(raw_signal, 2);
% data_size = 2000;
% max_height = 20000; %[m]

R0 = floor(6375/3.75);          %7200 m was concluded from Rayleigh fit (reference height)
data_range = 1:R0;
mol_data_size = length(data_range); % Molecular data range
trigger_delay_bins = 34;

%% Optical products matrix definition

alpha_total = zeros(R0, size(signal, 2), size(signal, 3));
beta_total = zeros(R0, size(signal, 2), size(signal, 3));
local_time = zeros(1, size(signal, 2));
inte = zeros(size(signal, 1), 1);
AOD_aer = zeros(1, size(signal, 2), size(signal, 3)); % AOD = Aerosol Optica Depth

% Choose 1 for p or 2 for s
m = 1;

beta_aer_matrix = zeros(size(signal, 1), size(signal,2), size(signal, 3));

%%
%DARK CURRENT = This data have to be substracted from the Lidar profile
if ~isempty(file_names_DC)
    fid = fopen(file_names_DC{1});
    dark_current = textscan(fid,'%s %s %s %s');
    fclose(fid);
    DC = str2double(dark_current{1,m}(58:end));
    %DC = str2double(dark_current{1,m}(20:end));
    DC = zeros(length(DC), length(file_names_DC));

for file_index = 1:length(file_names_DC)
    fid = fopen(file_names_DC{file_index});
    dark_current = textscan(fid,'%s %s %s %s');
    fclose(fid);
    DC(:, file_index) = str2double(dark_current{1,m}(58:end));
end

    DC( :, ~any(DC,1) ) = [];
    DC = mean(DC, 2); 
end

%%
for file_index = 1:num_of_files
    fid = fopen(file_names_RS{file_index});
    strData = textscan(fid,'%s %s %s %s');
    fclose(fid);

    %nos saltamos la cabecera de los datos (30) y los primeros 5 datos ya que
    %estos son el delay entre fotoconteo y analogo % ALICE (40:8190)
    S_raw = str2double(strData{1,m}(58:end));
    if length(S_raw) ~= length(DC)
        dif = size(DC,1) - size(S_raw,1);
        DC(end:-dif) = [];
    end
    %DC = DC(6:end,1,1); S_raw = S_raw(2667:end,1,1);
    S_raw = S_raw - DC;
    
    % Background correction
    S_raw = S_raw - mean(S_raw(15000:end));
    
    R = (0: length(S_raw(1:5000)) - 1) * 3.75;
    RCS = S_raw(1:5000) .* R' .* R'; %Range Corrected Signal

    rcs_matrix_CH0(:, file_index) = smooth(RCS, 0.006, 'loess'); %#ok<*SAGROW> 
    signal_CH0(:, file_index) = smooth(S_raw(1:5000), 0.01, 'loess');

    Fhora = file_names_RS{file_index}(end-12:end-8);
    local_time(:, file_index) = datenum([Fhora(1:2) ':' Fhora(4:5)], 'HH:MM');

    RCSm = RCS(R0);

    factor1 = (2) .* trapz(beta_mol(data_range) .* LR_mol) * (3.75);
    factor2 = (2) .* trapz(beta_mol(data_range) .* LRaer) * (3.75);

    numerador = RCS(data_range) ./ RCSm ./ exp(factor1) .* exp(factor2);
    factor = numerador .* LRaer;
    denominador = (1 ./ beta_mol(R0)) + (2) * trapz(factor) * (3.75);

    beta_total = abs(numerador ./ denominador);
    alfa = abs(LRaer .* beta_total + (LR_mol - LRaer) .* beta_mol(data_range, 1));
    alfa2 = LRaer .* beta_total;

    %CALCULO ALFA Y BETA AEROSOLES

    alfa_aer = (alfa - alpha_mol(data_range));
    beta_aer = abs(beta_total - beta_mol(data_range));

    LR = alfa_aer ./ beta_aer;

    alpha_aer_CH0(:, file_index) = alfa_aer;
   
    beta_aer_CH0(:, file_index) = beta_aer; 

    AOD_aer_CH0(:,file_index) = trapz(alfa_aer);

    fprintf('Processed File: %d/%d\r', file_index, num_of_files);
    
    
end

%%

user_choice = menu('Choose the optical product profile you want to display: ', 'Beta aerosol CH0','Beta aerosol CH1','Alpha aerosol CH0', 'Alpha aerosol CH1');
product = {beta_aer_CH0, beta_aer_CH0, alpha_aer_CH0, alpha_aer_CH0};

Fhora = zeros(1,size(file_names_RS,2));
for file_index = 1:num_of_files
    Fhora(1,file_index) = str2num(file_names_RS{file_index}(end-12:end-8));                             
    %local_time(:, file_index) = daGtenum([Fhora(1:2) ':' Fhora(4:5)], 'HH:MM');
end

local_time = Fhora;         % Vector en el que se almacenan las horas

switch (user_choice)
    case 1         % Beta aerosol CH0
        i = 1;
        optical_products(i,beta_aer_CH0,R,LRaer,day,month,year,Fhora);
    case 2         % Beta aerosol CH1
        i = 2;
        optical_products(i,beta_aer_CH0,R,LRaer,day,month,year,Fhora);
    case 3         % Alpha aerosol CH0
        i = 3;
        optical_products(i,beta_aer_CH0,R,LRaer,day,month,year,Fhora);
    case 4         % Alpha aerosol CH1
        i = 4;
        optical_products(i,beta_aer_CH0,R,LRaer,day,month,year,Fhora);
   
end

%     aer=[R(dataRange), beta_aer*10^6, alfa_aer*10^6, LRaer2(dataRange),betam(1:R0)*10^6,alfam(dataRange)*10^6];

toc

