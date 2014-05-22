%% Nov. 18, 2013, Chen Wang
% Draw max/min/std bars on the average curve from 100 times of testing Agents results 
% drawBars.m


clear all;
close all;
clc;

rst_dirs = {'./rst1115/random_run', './rst1116/greedy_run', './rst1117/greedyRnd30_run', './rst1118/greedyRnd50_run'};
img_titles = {'Random Agents', 'Greedy Agents', 'Greedy Agents with 30% Randomness', 'Greedy Agents with 50% Randomness'};
img_names = {'./imgRsts/random_rngs.png', './imgRsts/greedy_rngs.png', './imgRsts/grdRnd30_rngs.png', './imgRsts/grdRnd50_rngs.png'};
curve_specs = {'--r', '-.b', '-*k', '-xg'};


%% Draw averaged curves and min/max bars

for g = 1 : length(rst_dirs)
    % Load the first run
    cur_sla = load([rst_dirs{g} '1_sla.mat']);
    cur_sla = cur_sla.violated_agents_curve(:, 2);
    
    % The duration of total iterations.
    duration = length(cur_sla);
    t = 1 : duration;
    total_violated_percentage = zeros(duration, 1000);
    total_violated_percentage(:, 1) = cur_sla;

    for runID = 2 : 1000
        dat_name = [rst_dirs{g} num2str(runID) '_sla.mat'];
        cur_sla = load(dat_name);
        cur_sla = cur_sla.violated_agents_curve(:, 2);
        total_violated_percentage(:, runID) = cur_sla;
    end
    
    max_violated_percentage = max(total_violated_percentage, [], 2);
    min_violated_percentage = min(total_violated_percentage, [], 2);
    mean_violated_percentage = mean(total_violated_percentage, 2);
    std_violated_percentage = std(total_violated_percentage, 1, 2);
    
    U = max_violated_percentage - mean_violated_percentage;
    L = mean_violated_percentage - min_violated_percentage;
    
    f = figure(g);
    hold on;
    % errorbar(mean_violated_percentage, std_violated_percentage, curve_specs{g});
    title(img_titles{g});
    errorbar(t, mean_violated_percentage, L, std_violated_percentage, curve_specs{g});
    plot(mean_violated_percentage, '-w', 'LineWidth', 2);
    axis([0 1100 0 0.25]);
    xlabel('The iteration number');
    ylabel('The SLA violation ratio');
    hold off;
    
    print(f, '-dpng', img_names{g});
end
