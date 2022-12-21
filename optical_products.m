%% Function optical_products
% This function allows the user to set the basic configuration of the plots that will be generated such
% as automatic titles, angle of elevation, date, how many profiles are going to be retrieved, in what
% time intervals are going to be integrated. The program is called for plotting backscattering 
% and extinction coefficient.
% NOTE: quantity_index variables is the one that determines if Beta or Alpha will be plotted.
% ------------------------------------------------------------------------------------------------------------
%                                           Code developed by Pablo Aguirre - Alvarez on 2022
%------------------------------------------------------------------------------------------------------------

function optical_products(quantity_index, beta_aer_CH0,R,LRaer,day,month,year, Fhora)

% The following questions aim to determine which label is going to be assigned to Y label
elev = string(input('Measurements were taken with an elevation angle different to the zenith? Y/N: ','s'));
if elev == 'Y'
    elev_angle = input('Please insert the elevation angle: ');
else
    elev = 'N';
    elev_angle = 0;
end
zenith = string(90-elev_angle);                             % Only for title writing purposes

y_label = {'Radial distance [m]','Altitude a.g.l [m]'};
if elev == "Y"
    y_label = y_label(1);
elseif elev == "N"
        y_label = y_label(2);
end

% Request for number of profiles that will be integrated
n = input('Please insert how many profiles do you want to retrieve: ');
options = cell(1,2*n);
v = [1:n]; v = sort([v,v]);                                         % Vector for saving profiles quantities

% Time interval definition
date = datetime(year, month, day);
date.Format = 'dd MMM yyyy';
wavelength = '532';

local_time = Fhora;                                              % In this vector we save the time
start_hour = num2str(min(Fhora));                       
end_hour = num2str(max(Fhora));

% The user is asked which files want to analize:
for i =1:2*n
    if mod(i,2) == 1
        options{1,i} = strcat('Enter initial file for profile',' - ',num2str(v(i)));
    elseif mod(i,2) == 0
        options{1,i} = strcat('Enter ending file for profile ','- ',num2str(v(i)));
    end
end

% Configuration of the menu displayed
dlgtitle = 'Input';     
dims = [1 50];      % Width and height of the box
files_time = inputdlg(options,dlgtitle,dims);
f = figure('Color','white');
color_list = ['r','b','k','m','c']; col_n = 1;

% Legend settings so the user can know the time automatically for the previously selected files:
Legend = cell(n,1);i_cell = 1;
for iter = 1:2:length(v)
    init_f = str2double(files_time(iter)); end_f = str2double(files_time(iter+1));
    Legend{i_cell} = string(strcat(num2str(Fhora(init_f)),{' - '},num2str(Fhora((end_f)))));    % This will be written as a legend
    i_cell = i_cell + 1;
end

% Profile integration and plotting:
for profile_index = 1:2:length(v)
    % init_f: lower integration limit.   end_f: upper integration limit
    init_f = str2double(files_time(profile_index)); end_f = str2double(files_time(profile_index+1));
    disp(init_f)
    disp(end_f)
    profile = mean(beta_aer_CH0(:,init_f:end_f), 2);    % Integration
    profile = smooth(profile, 0.01,'loess');                  % Smoothing
    alpha_profile = profile * LRaer;
    alpha_profile = smooth(alpha_profile,0.05,'loess');
    % Plotting:
    if quantity_index == 1
        profile_for_plot = profile; label_x = 'Backscattering coefficient [m^{-1} sr^{-1}]'; title_variable = '\beta';
    elseif quantity_index == 3
        profile_for_plot = alpha_profile; label_x = 'Extinction coefficient [m^{-1}]'; title_variable = '\alpha';
    end
    if col_n <= n
        plot_profile = plot(profile_for_plot, R(1:1700), 'LineWidth', 1.3, 'Color', color_list(col_n) ,'DisplayName','cos'); hold on
        col_n = col_n + 1;
    end
    xlim([0 inf]); ylim([0 max(R(1:1700))]); legend(Legend)         % Axis limits
end

xlabel(label_x, 'FontSize', 21); ylabel(y_label,'FontSize',21);      % Axis labels

title(strcat({' '},title_variable,' - \lambda = ', {' '}, wavelength, ' nm -', 'at \theta = ',{''},zenith,{'°.'},datestr(date), ' - ',{' '},...
    start_hour,' to ',{' '},end_hour,' UTC-5 - Medellín - Colombia'), 'FontSize', 22)

end
