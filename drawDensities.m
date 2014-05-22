%% Nov. 18, 2013, Chen Wang
% Draw density curves of testing Agents results 
% drawDensities.m


clear all;
close all;
clc;

rst_dirs = {'./rst1115/random_run', './rst1116/greedy_run', './rst1117/greedyRnd30_run', './rst1118/greedyRnd50_run'};
img_titles = {'Random Agents', 'Greedy Agents', 'Greedy Agents with 30% Randomness', 'Greedy Agents with 50% Randomness'};
img_names = {'./imgRsts/random_density.png', './imgRsts/greedy_density.png', './imgRsts/grdRnd30_density.png', './imgRsts/grdRnd50_density.png'};
curve_specs = {'--r', '-.b', '-*k', '-xg'};


%% Draw averaged curves and min/max bars
for g = 1 : length(rst_dirs)
    % Load the first run
    cur_sla = load([rst_dirs{g} '1_sla.mat']);
    cur_sla = cur_sla.violated_agents_curve(:, 2);
    
    % The duration of total iterations.
    duration = length(cur_sla);
    t = 1 : duration;
    X = t';
    Y = cur_sla;

    for runID = 2 : 1000
        dat_name = [rst_dirs{g} num2str(runID) '_sla.mat'];
        cur_sla = load(dat_name);
        cur_sla = cur_sla.violated_agents_curve(:, 2);
        X = [X; t'];
        Y = [Y; cur_sla];
    end
    mn_Y = mean(Y, 2); 
    
    f = figure(g);
    hold on;
    % errorbar(mean_violated_percentage, std_violated_percentage, curve_specs{g});
    title(img_titles{g});
    DataDensityPlot( X, Y, 256);
    plot(mn_Y, '-w', 'LineWidth', 2);
    axis([0 1100 0 0.5]);
    xlabel('The iteration number');
    ylabel('The SLA violation ratio');
    hold off;
    
    print(f, '-dpng', img_names{g});
end
