%% KLETT - FERNALD - SASANO ALGORITHM IMPLEMENTATION.
%
% This program has been developed by Manuela Hoyos-Restrepo based on the
% code developed by Elena Montilla-Rosero and edited by Pablo Aguirre-Álvarez. 
%
% The code allows to retrieve backscattering and extinction coefficients from standard atmosphere pression,
% height and temperature profiles saved in a .TXT file and calls a function called molecular.m . This function
% and the .TXT, must to be saved in the same directory of this code.
%
% ----------------------------------------------------------------------------------------------------------
% Last edition on: 06-12-2022 by Pablo Aguirre-Álvarez.
% ----------------------------------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------------------------------

%% Standard Atmosphere data for molecular backscattering, Lidar Ratio and extinction calculation
% Meteorological data reading from standard atmosphere .TXT file:

%meteo_file = 'C:\Users\paguirrea\Desktop\Práctica Pablo 2022-2\Códigos MATLAB editados por Pablo\T-P prof Standard Atmosph.txt';
meteo_file = 'C:\Users\usuario\OneDrive - Universidad EAFIT\Códigos LIDAR pablo\T-P prof Standard Atmosph.txt';             % .TXT file path
meteo_file = dlmread(meteo_file, '\t', 1, 0);               % .TXT reading. Each column separated by tab
% Reading of pressure, height and temperature columns from .TXT
mol_pressure = (meteo_file(:, 3)) / 100;                    % [hPa]
mol_height = meteo_file(:, 1);                                  % [m]
mol_temperature = meteo_file(:, 2);                         % [K]

%% Molecular Beta and Alpha calculations
% molecular.m is called for calculating the molecular backscatter coefficient at 532 nm (beta_mol_532) and
% the molecular Lidar Ratio (LR_mol). The wavelength is given in micrometers as an input for molecular.m

wavelength_um = 0.532;
[beta_mol_532, LR_mol] = molecular(mol_pressure, mol_temperature, wavelength_um);
R_mol = ((1 : size(signal, 1)) * 3.75)';

altitude_lidar = 1495;                                              % Medellin elevation m.s.a.l (meters above sea level)
% beta_mol = exp(interp1(mol_height, log(beta_mol_532), R_mol + altitude_lidar, 'linear', 'extrap'));
beta_mol = exp(interp1(mol_height, log(beta_mol_532), R_mol, 'linear', 'extrap'));     
alpha_mol = LR_mol .* beta_mol;

%% Data initialization

LRaer = 61;                                                             % LR for aerosols in Medellin = 61 [sr] (M.Hoyos, 2022) 

num_of_files = size(raw_signal, 2);                           % Number of RS files
data_size = 2000;
max_height = 20000;                                              % Maximum height [m]

R0 = floor(6375/3.75);                                             % Reference height in bins (See Rayleigh fit) (M.Hoyos, 2022)
data_range = 1:R0;
mol_data_size = length(data_range);                       % Molecular data range
trigger_delay_bins = 28;                                          % (M.Hoyos, 2022)

%% Optical products matrix definition

alpha_total = zeros(R0, size(signal, 2), size(signal, 3));
beta_total = zeros(R0, size(signal, 2), size(signal, 3));
local_time = zeros(1, size(signal, 2));
inte = zeros(size(signal, 1), 1);
AOD_aer = zeros(1, size(signal, 2), size(signal, 3));       % AOD = Aerosol Optical Depth
beta_aer_matrix = zeros(size(signal, 1), size(signal,2), size(signal, 3));

% Choose 1 for p or 3 for s
m = 1;

%%
%DARK CURRENT = This data has to be substracted from the Lidar profile
if ~isempty(file_names_DC)
    fid = fopen(file_names_DC{1});
    dark_current = textscan(fid,'%s %s %s %s');
    fclose(fid);
    DC = str2double(dark_current{1,m}(58:end));
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

%% KFS Algorithm
% The method is applied once to every RS file:
for file_index = 1:num_of_files
    fid = fopen(file_names_RS{file_index});
    strData = textscan(fid,'%s %s %s %s');
    fclose(fid);

    % In case you want to analize s channel, then make m = 3 in a previous section
    S_raw = str2double(strData{1,m}(58:end));            % Raw Signal reading
    % Correction of vectors dimmensions in case RS and DC sizes are not equal:
    if length(S_raw) ~= length(DC)
        dif = size(DC,1) - size(S_raw,1);
        DC(end:-dif) = [];
    end
    S_raw = S_raw - DC;                                             % DC correction
    S_raw = S_raw - mean(S_raw(15000:end));             % Background correction
    
    R = (0: length(S_raw(1:5000)) - 1) * 3.75;              % Height of interest for range correction
    RCS = S_raw(1:5000) .* R' .* R';                            % Range Corrected Signal

    % RCS and Raw Signal matrices for channel 0  (m = 1)
    rcs_matrix_CH0(:, file_index) = smooth(RCS, 0.006, 'loess'); %#ok<*SAGROW> 
    signal_CH0(:, file_index) = smooth(S_raw(1:5000), 0.01, 'loess');

   % Time capture from files names
    Fhora = file_names_RS{file_index}(end-12:end-8);
    local_time(:, file_index) = datenum([Fhora(1:2) ':' Fhora(4:5)], 'HH:MM');

    RCSm = RCS(R0);                                                 % Molecular signal at reference height

    % This factors are explained in the repository. See: https://github.com/optica-ambiental-eafit/LiMonDataProcessing
    factor1 = (2) .* trapz(beta_mol(data_range) .* LR_mol) * (3.75);
    factor2 = (2) .* trapz(beta_mol(data_range) .* LRaer) * (3.75);

    numerator = RCS(data_range) ./ RCSm ./ exp(factor1) .* exp(factor2);
    factor = numerator .* LRaer;
    denominator = (1 ./ beta_mol(R0)) + (2) * trapz(factor) * (3.75);

    beta_total = abs(numerator ./ denominator);
    alfa = abs(LRaer .* beta_total + (LR_mol - LRaer) .* beta_mol(data_range, 1));
    alfa2 = LRaer .* beta_total;

    % Beta and Alpha coefficients computing

    alfa_aer = (alfa - alpha_mol(data_range));
    beta_aer = abs(beta_total - beta_mol(data_range));

    LR = alfa_aer ./ beta_aer;

    alpha_aer_CH0(:, file_index) = abs(alfa_aer);
   
    beta_aer_CH0(:, file_index) = beta_aer; 

    AOD_aer_CH0(:,file_index) = trapz(alfa_aer);

    fprintf('Processed File: %d/%d\r', file_index, num_of_files);
    
end

%% Profile plotting
% A menu is displayed so the user can choose the profiles to analize. The plot titles are generated automatically by the function profile_plots.m.

% Menu creation and selection of the titles for the figures:
user_choice = menu('Choose the optical product profile you want to display: ', 'Beta aerosol CH0','Beta aerosol CH1','Alpha aerosol CH0', 'Alpha aerosol CH1');
product = {beta_aer_CH0, beta_aer_CH0, alpha_aer_CH0, alpha_aer_CH0};

% Time capture from the files names:
Fhora = zeros(1,size(file_names_RS,2));
for file_index = 1:num_of_files
    Fhora(1,file_index) = str2num(file_names_RS{file_index}(end-12:end-8));                             
    %local_time(:, file_index) = daGtenum([Fhora(1:2) ':' Fhora(4:5)], 'HH:MM');
end
local_time = Fhora;                                               

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
