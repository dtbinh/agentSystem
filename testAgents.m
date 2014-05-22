%% Oct. 17, 2013, Chen Wang
% Testing the random, greedy and random-greedy agents in a considerable
% number of times and save the results
% testAgents.m

%% Logistics
clear all;
close all;
clc;
% warning off;

%% Initialize the system configurations.
sysConf.server_num = 12;
sysConf.server_capacity = 75;
sysConf.agent_num = 900;
sysConf.agent_candidates = 1 : sysConf.server_num;
sysConf.sla_th = 0.95 .* sysConf.server_capacity .* sysConf.server_num ./ sysConf.agent_num;
sysConf.agent_life_duration = 50;
sysConf.rsc_util = 0.9;
sysConf.decay_factor = 0.9;
sysConf.iter_num = 1000;
sysConf.video_mode = 'off';      % 'on': show the video; 'off': turn off the video.
sysConf.graph_mode = 'off';      % 'on': save the graph; 'Off': do not save the graph.
sysConf.data_mode = 'on';        % 'on': save data into result directory,  

%% Run 100 times of greedyRnd30 agents and save the data to csv files.
sysConf.agent_typ = 'greedyRnd';
for topN = 1 : sysConf.server_num
    sysConf.rst_dir = ['./rst1120/greedyRnd' num2str(topN) '/'];
    sysConf.topN = topN;
    if ~exist(sysConf.rst_dir, 'dir')
        mkdir(sysConf.rst_dir);
    end
    total_violated_agents_curve = zeros(sysConf.iter_num, 1);
    for runID = 1 : 1000
        [violated_agents_curve, ~] = agentSystem(sysConf, runID);
        total_violated_agents_curve = total_violated_agents_curve + violated_agents_curve(:, 2);
        % figure(1), plot(total_violated_agents_curve./runID);
    end
end

%% Run 100 times of random agents and save the data to csv files.
sysConf.agent_typ = 'random';
sysConf.rst_dir = './rst1120/random/';
if ~exist(sysConf.rst_dir, 'dir')
    mkdir(sysConf.rst_dir);
end
total_violated_agents_curve = zeros(sysConf.iter_num, 1);
for runID = 1 : 1000
    [violated_agents_curve, ~] = agentSystem(sysConf, runID);
    total_violated_agents_curve = total_violated_agents_curve + violated_agents_curve(:, 2);
    % figure(1), plot(total_violated_agents_curve./runID);
end

%% Run 100 times of greedy agents and save the data to csv files.
sysConf.agent_typ = 'greedy';
sysConf.rst_dir = './rst1120/greedy/';
if ~exist(sysConf.rst_dir, 'dir')
    mkdir(sysConf.rst_dir);
end
total_violated_agents_curve = zeros(sysConf.iter_num, 1);
for runID = 1 : 1000
    [violated_agents_curve, ~] = agentSystem(sysConf, runID);
    total_violated_agents_curve = total_violated_agents_curve + violated_agents_curve(:, 2);
    % figure(1), plot(total_violated_agents_curve./runID);
end