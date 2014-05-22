%% Nov. 25, 2013, Chen Wang
% Count the statistics of results from multiple runs of different type of
% agents (1000 time runs).
% cntStats.m

clc;
clear all;
close all;

rst_dir = './rst1120/greedyRnd';
curve_specs = {'--r', '-.b', '-*k', '-xg'};

%% Iterations among top n number of randomness in greedy agents.
% Randomly sample the iterations after warm-up period.
warmup_period = 200;
per_run_spl = 100;
run_no = 1000;

rsc_util = (1 : 12) ./ 12;
ave_mn = zeros(12, 1);

for n = 1 : 12
    % Load the first run
    cur_sla = load([rst_dir num2str(n) '/greedyRnd_run' '1_sla.mat']);
    cur_sla = cur_sla.violated_agents_curve(:, 2);
    total_iters = length(cur_sla);
    curve_mean = zeros(run_no, 1);
    curve_std = zeros(run_no, 1);
    curve_mean(1) = mean(cur_sla(warmup_period : end));
    curve_std(1) = std(cur_sla(warmup_period : end));

    if run_no > 1
        for runID = 2 : run_no
            dat_name = [rst_dir num2str(n) '/greedyRnd_run' num2str(runID) '_sla.mat'];
            cur_sla = load(dat_name);
            cur_sla = cur_sla.violated_agents_curve(:, 2);
            cur_curve_mean = mean(cur_sla(warmup_period : end));
            cur_curve_std = std(cur_sla(warmup_period : end));
            curve_mean(runID) = cur_curve_mean;
            curve_std(runID)= cur_curve_std; 
        end
    end
    
    spl_mean = mean(curve_mean);
    ave_mn(n) = spl_mean;
    spl_std = mean(curve_std);
    
    disp(['GreedyRandom-' num2str(n) ' with ' num2str(run_no) ' runs: Mean ---- ' num2str(spl_mean) '; Std ---- ' num2str(spl_std)]);
end

figure(1);
plot(rsc_util, ave_mn, 'LineWidth', 2);
xlabel('The percentage of randomness in greedy agents');
ylabel('The average sla violation rates over 1000 runs');