%%  RCS profile comparison.
%     This code generates a comparison between profiles in heights defined
%     by the user for different times of measurement.

init_bin = 1; end_bin = 500;
profile_0 = mean(RCS(init_bin:end_bin,10:80,1),2); profile_0sm = smooth(profile_0,'sgolay',4);
profile_1 = mean(RCS(init_bin:end_bin,100:300,1),2);
profile_2 = mean(RCS(init_bin:end_bin,300:400,1),2);
profile_3 = mean(RCS(init_bin:end_bin,400:500,1),2); profile_3sm = smooth(profile_3,'sgolay',4);
profile_4 = mean(RCS(init_bin:end_bin,:,1),2);

height = linspace((init_bin*3.75)/1000,(end_bin*3.75)/1000,size(profile_0,1)); height = height';

figure
plot(profile_0,height, 'LineWidth', 3, 'Color', 'r'); hold on
%plot(profile_0sm,height, '-.', 'LineWidth', 3, 'Color', 'k'); hold on
plot(profile_1, height, 'LineWidth', 3, 'Color', 'b'); hold on;
plot(profile_2, height, 'LineWidth', 3, 'Color', 'k'); hold on;
plot(profile_3, height, 'LineWidth', 3, 'Color', 'g'); hold on;
%plot(profile_3sm, height, 'o','LineWidth', 3, 'Color', 'b'); hold on;
% plot(profile_4, height, 'LineWidth', 3, 'Color', 'm'); hold on;

xtickformat('%.2f');
grid('on');
ax = gca;
ax.FontSize = 12;
ylabel('Altitude a.g.l [km]', 'FontSize', 12);
xlabel('RCS integrated signal [mV]', 'FontSize', 12);
ylim([min(height) max(height)]);
test_date = datetime(year, month, day);
test_date.Format = 'dd MMMM yyyy';
title(strcat('Integrated RCS',{' '},char(test_date), ' - Medellín - LiMon'), 'FontSize', 12);
legend('Time 0','Time 1','Time 2','Time 3','Integrated')