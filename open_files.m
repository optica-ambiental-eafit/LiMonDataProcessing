function [lidar_varName] = open_files(path)

path = strcat(path, '\RS*');                                            % Por qué \RS*????? Se cambia manualmente la ruta aquí?
tmp = dir(path);
disp(tmp)
disp(path)
path = strcat(tmp(1).folder, '\', tmp(1).name);
file_names = importdata(path);
if size(file_names.data, 2) > 2
    lidar_varName = zeros(size(file_names.data, 1), length(tmp), size(file_names.data, 2)/2);
else
    lidar_varName = zeros(size(file_names.data, 1), length(tmp));
end
for file = 1 : length(tmp)
    path = strcat(tmp(file).folder, '\', tmp(file).name);
    file_names = importdata(path);
    if ~ismatrix(lidar_varName)
        %         for channel = 1 : size(lidar_varName, 3)
        %             lidar_varName(:, file, channel) = file_names.data(:, channel+1);
        %         end
        lidar_varName(:, file, :) = file_names.data(:, 1:2:size(file_names.data, 2)-1);
    else
        lidar_varName(:, file) = file_names.data(:, 1);
    end
    
end
disp(size(lidar_varName))
% lidar_varName = mean(lidar_varName, 2);
end