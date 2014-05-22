%% Nov. 18, 2013, Chen Wang
% Draw the average curve from 100 times of testing Agents results 
% drawAveRsts.m

clear all;
close all;
clc;

rst_dirs = {'./rst1115/random_run', './rst1116/greedy_run', './rst1117/greedyRnd30_run', './rst1118/greedyRnd50_run'};
curve_specs = {'--r', '-.b', '-*k', '-xg'};


%% Draw averaged curves
% figure(1), hold on;
% for g = 1 : length(rst_dirs)
%     % Load the first run
%     cur_sla = load([rst_dirs{g} '1_sla.mat']);
%     total_violated_percentage = cur_sla.violated_agents_curve(:, 2);
% 
%     for runID = 2 : 1000
%         dat_name = [rst_dirs{g} num2str(runID) '_sla.mat'];
%         cur_sla = load(dat_name);
%         cur_sla = cur_sla.violated_agents_curve(:, 2);
%         total_violated_percentage = total_violated_percentage + cur_sla;
%     end
%     
%     plot(total_violated_percentage ./ runID, curve_specs{g});
% end
% 
% xlabel('The time iterations'); ylabel('The percentage of SLA violations');
% legend('Random', 'Greedy', 'GreedyRnd30', 'GreedyRnd50');
% hold off;

%% Randomly sample the iterations after warm-up period.
warmup_period = 200;
per_run_spl = 100;
run_no = 1000;

for g = 1 : length(rst_dirs)
    % Load the first run
    cur_sla = load([rst_dirs{g} '1_sla.mat']);
    cur_sla = cur_sla.violated_agents_curve(:, 2);
    total_iters = length(cur_sla);
    curve_mean = zeros(run_no, 1);
    curve_std = zeros(run_no, 1);
    curve_mean(1) = mean(cur_sla(warmup_period : end));
    curve_std(1) = std(cur_sla(warmup_period : end));

    if run_no > 1
        for runID = 2 : run_no
            dat_name = [rst_dirs{g} num2str(runID) '_sla.mat'];
            cur_sla = load(dat_name);
            cur_sla = cur_sla.violated_agents_curve(:, 2);
            cur_curve_mean = mean(cur_sla(warmup_period : end));
            cur_curve_std = std(cur_sla(warmup_period : end));
            curve_mean(runID) = cur_curve_mean;
            curve_std(runID)= cur_curve_std; 
        end
    end
    
    spl_mean = mean(curve_mean);
    spl_std = mean(curve_std);
    
    disp([rst_dirs{g} ' with ' num2str(run_no) ' runs: Mean ---- ' num2str(spl_mean) '; Std ---- ' num2str(spl_std)]);
end

