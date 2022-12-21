%% Function profile_plots
% This function allows to plot the signal profiles individually and/or all together as subplots in a figure.
% Signal profiles that can be retrieved using this function (for both channel 0 and 1):
% # Raw Signal
% # Raw Signal - DC
% # Raw Signal - DC - Background
% # DC
% # DC with spurius data filtered
% Once the figure is created, mean and maximum values for each signal are calculated and written in
% the legend for making the analysis more simple.
% --------------------------------------------------------------------------------------------------------------
%                               Code developed by Pablo Aguirre - Alvarez on 2022
% --------------------------------------------------------------------------------------------------------------

function profile_plots(values_0,values_1,titles,index,height,year,month,day)
        % Axis configuration and plotting
        xmin = min([min(values_0) min(values_1)]);
        xmax = max([max(values_0) max(values_1)]);
        profile_plot = plot(values_0, height/1000, 'LineWidth', 3, 'Color', 'k');
        hold on
        profile_plot = plot(values_1, height/1000, 'LineWidth', 3, 'Color', 'b');
        % Figure configuration:
        xtickformat('%.3f');
        grid('on');
        ax = gca;
        fig = gcf;
        set(gcf,'color','w');
        ax.FontSize = 12;
        ylabel('Altitude a.g.l [km]', 'FontSize', 17);
        xlabel('Raw Signal [mV]', 'FontSize', 17);
        test_date = datetime(year, month, day);
        test_date.Format = 'dd/MM/yyyy';
        title(strcat(titles{index},{'. '},char(test_date), ' - Medellín - LiMon'), 'FontSize', 17);
        
        % index variable determines if you want to calculate max and mean or just max:
        if index==2
            labels = sprintf('Channel 0 mean & max [mV]: %f & %f',mean(values_0,'includenan'),max(values_0));
            labels1 = sprintf('Channel 1 mean & max [mV]: %f & %f',mean(values_1,'includenan'),max(values_1));
        else
            labels = sprintf('Channel 0 max [mV]: %f',max(values_0));
            labels1 = sprintf('Channel 1 max [mV]:  %f',max(values_1));
        end
        
        legend(labels,labels1,'Location','best')

end


