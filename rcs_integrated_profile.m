profile_0 = mean(RCS(:,10:80,1),2);
profile_1 = mean(RCS(:,10:80,2),2);
height = linspace(0,60000,size(raw_signal,1)-trigger_delay_bins+1); height = height';

plot(profile_0,height/1000, 'LineWidth', 3, 'Color', 'r');
hold on
plot(profile_1, height/1000, 'LineWidth', 3, 'Color', 'b');
xtickformat('%.2f');
grid('on');
ax = gca;
ax.FontSize = 12;
ylabel('Altitude a.g.l [km]', 'FontSize', 12);
xlabel('RCS integrated signal [mV]', 'FontSize', 12);
ylim([0 (1700*3.75)/1000]);
test_date = datetime(year, month, day);
test_date.Format = 'dd MMMM yyyy';
title(strcat('Integrated RCS',{' '},char(test_date), ' - Medellín - LiMon'), 'FontSize', 12);
legend('Channel 0','Channel 1')
