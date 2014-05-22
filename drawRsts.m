%% Draw results in rst1113
% Chen Wang, 11-13-2013

clear all;
close all;

dir_name = './rst1113/beta0.9_L50_';

sla_names = {'Random_sla.mat', 'Greedy_sla.mat', 'GrdRnd0.3_sla.mat', 'GrdRnd0.5_sla.mat'};
cdf_names = {'Random_sessions.mat', 'Greedy_sessions.mat', 'GrdRnd0.3_sessions.mat', 'GrdRnd0.5_sessions.mat'};
curve_specs = {'--r', '-.b', '-*k', '-xg'};
curve_markers = {'+', '.', '*', 'x'};
curve_colors = {'r', 'b', 'k', 'g'};

% f1 = figure(1);
% hold on;
% title('SLA Violations Time Curve', 'FontSize', 16);
% xlabel('The number of iterations');
% ylabel('The number of SLA violations');
% 
% for i = 1 : length(sla_names)
%     dat = load([dir_name sla_names{i}]);
%     curve = dat.violated_agents_curve(:, 2) ./ (dat.violated_agents_curve(:, 1) .* 900);
%     plot(curve, curve_specs{i}, 'LineWidth', 2);
%     
%     ratio = mean(curve);
%     disp(['Mean SLA Violations over 500 iterations is: ' num2str(ratio)]);
% end
% 
% legend('Random Agent', 'Greedy Agents', 'Top 30% Random in Greedy', 'Top 50% Random in Greedy', 'location', 'NorthWest');
% 
% hold off;
% 
% print(f1, '-dpng', './rst1113/comparison_time_curve.png');

f2 = figure(2);
hold on;
title('The CDF of SLA violation time percentage.', 'FontSize', 16);

for i = 1 : length(cdf_names)
    dat = load([dir_name cdf_names{i}]);
    data = dat.video_sessions;
    p_h = cdfplot(data);
    set(p_h, 'LineWidth', 2, 'Color', curve_colors{i}, 'Marker', curve_markers{i});
    
    ratio = mean(data);
    disp(['Mean time percentage of SLA violations for all sessions (' cdf_names{i} ') : '  num2str(ratio)]);
end

legend('Random Agent', 'Greedy Agents', 'Top 30% Random in Greedy', 'Top 50% Random in Greedy', 'location', 'SouthEast');
xlabel('The Time Percentage of SLA violation'), ylabel('The percentage of agents');

hold off;

print(f2, '-dpng', './rst1113/comparison_time_percentage.png');