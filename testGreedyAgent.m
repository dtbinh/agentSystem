%% Oct. 17, 2013, Chen Wang
% Simulating the stability of greedy agents that measure servers' capacity
% based on the assumption that all agents know all servers' capacity.
% testGreedyAgent.m

%% Logistics
clear all;
close all;
clc;
warning off;

%% Create a list of servers
server_num = 12;
% nodes array stores the status of each server.
servers = zeros(server_num, 1); 
server_capacity = 75;

%% Create a list of clients
agent_num = 900;
agent_candidates = server_num;

max_agent_capacity = server_num * server_capacity / agent_num;
th = 0.95;

%% Initialize agent_matrix and randomly allocate each agent to one of the
% servers in agents' candidates.
agent_array = randi(agent_candidates, agent_num, 1);
agent_state_matrix = zeros(agent_num, server_num);
agent_cap = zeros(agent_num, 1);
agent_alive = zeros(agent_num, 1);

server_avail_capacity = zeros(server_num, 1);

% Initialize image to be shown
death_color = [1 1 1];
bg = {'w','k'};
colors = distinguishable_colors(server_num, bg);
B = 30;
H = 30;
life_duration = 50;

sc_img = draw_agents(agent_array, agent_alive, colors, death_color, B, H);
cap_img = draw_agent_cap(agent_cap, B, H, max_agent_capacity);
agent_switch_p = zeros(agent_num, 1);
p_img = draw_agent_cap(agent_switch_p, B, H, max_agent_capacity);

fig = figure(1);
set(fig, 'Position', [0 100 1400 400]);
fig_iter = annotation('textbox', [0.1 0.05 0.1 0.1], 'String', 'Iteration: 0', 'FontSize', 24, 'FitBoxToText', 'on', 'EdgeColor', 'none');
fig_res = annotation('textbox', [0.25 0.05 0.1 0.1], 'String', 'Resource Utilization: 0', 'FontSize', 24, 'FitBoxToText', 'on', 'EdgeColor', 'none');
fig_sla = annotation('textbox', [0.5 0.05 0.1 0.1], 'String', 'SLA Violations: 0', 'FontSize', 24, 'FitBoxToText', 'on', 'EdgeColor', 'none');
subplot(1, 4, 1), imshow(sc_img), title('Server for each agent', 'FontSize', 16);
subplot(1, 4, 2), imshow(cap_img), title('Capacity for each agent', 'FontSize', 16);
subplot(1, 4, 3), imshow(p_img), title('Switching Probability for each agent', 'FontSize', 16);
subplot(1, 4, 4);
h4 = cdfplot(agent_cap); 
set(h4, 'linewidth', 2); 
title('The CDF of agent capacity', 'FontSize', 16), xlabel('The Capacity in agents'), ylabel('The cumulative probability');

%% Write Images to a Video
% Server video
rst_file_name = './rst1113/beta0.9_L50_GrdRnd0.5_R2';
rstVideo = VideoWriter([rst_file_name '.mp4'], 'MPEG-4');
rstVideo.FrameRate = 5;
open(rstVideo);
curFrame = getframe(fig);
writeVideo(rstVideo,curFrame);

%% Start iteration
iter = 1;
beta = 0.9;
alpha = 0.9;
lambda = beta * agent_num / life_duration;
violated_agents_curve = [];
total_violated_iterations = [];

% while ((sum(agent_alive > 0) < agent_num * beta) || (switched_agents ~= 0)) && (iter < 500)
while (iter < 500)
    
    %% Update the birth and death of agent_alive
    agent_alive = update_agent_life(agent_alive, lambda, life_duration);
    agent_cap(agent_alive == 0) = 0;
    
    for i = 1 : server_num
        if sum((agent_array == i) & (agent_alive > 0)) == 0
            server_avail_capacity(i) = server_capacity;
        elseif sum((agent_array == i) & (agent_alive > 0)) * max_agent_capacity < server_capacity
            server_avail_capacity(i) = server_capacity - sum((agent_array == i) & (agent_alive > 0)) .* max_agent_capacity;
            agent_cap((agent_array == i) & (agent_alive > 0)) = max_agent_capacity;
        else
            server_avail_capacity(i) = 0;
            agent_cap((agent_array == i) & (agent_alive > 0)) = server_capacity ./ sum((agent_array == i) & (agent_alive > 0));
        end   
    end
    
    % Count SLA violated agents.
    violated_agents = (agent_cap < th*max_agent_capacity) & (agent_alive > 0);
    total_violated_iterations = [total_violated_iterations (agent_alive > 0).*1 - 2.*violated_agents];
    violated_agents_num = sum(violated_agents);
    
    % Count the resource utilization rate
    res_rate = sum(agent_cap) ./ (server_capacity .* server_num);
    
    % Count the probability of agent switching
    agent_switch_p(agent_alive == 0) = 0;
    if violated_agents_num > 0
        % Linear Decayed Probability
        % agent_switch_p((agent_array) == i) = (life_duration - agent_alive((agent_array) == i))./(2.*life_duration);

        % Exponentially Decayed Probability
        agent_switch_p(violated_agents) = alpha.^agent_alive(violated_agents);
    else
        agent_switch_p = zeros(agent_num, 1);
    end
        
    
    
    %% Show the updated image.
    sc_img = draw_agents(agent_array, agent_alive, colors, death_color, B, H);
    cap_img = draw_agent_cap(agent_cap, B, H, max_agent_capacity);
    p_img = draw_agent_cap(agent_switch_p, B, H, max_agent_capacity);

    % fig = figure(1);
    set(fig, 'Position', [0 100 1400 400]);
    set(fig_iter, 'String', ['Iteration: ' num2str(iter)]);
    set(fig_res, 'String', ['Resource Utilization: ' num2str(res_rate)]);
    set(fig_sla, 'String', ['SLA Violations: ' num2str(violated_agents_num)]);
    subplot(1, 4, 1), imshow(sc_img), title('Server for each agent', 'FontSize', 16);
    subplot(1, 4, 2), imshow(cap_img), title('Capacity for each agent', 'FontSize', 16);
    subplot(1, 4, 3), imshow(p_img), title('Switching Probability for each agent', 'FontSize', 16);
    subplot(1, 4, 4);
    h4 = cdfplot(agent_cap); 
    set(h4, 'linewidth', 2); 
    title('The CDF of agent capacity', 'FontSize', 16), xlabel('The Capacity in agents'), ylabel('The cumulative probability');
    
    curFrame = getframe(fig);
    writeVideo(rstVideo,curFrame);
    
    %% Count Statistics on this iteration
    violated_agents_curve = [violated_agents_curve; res_rate violated_agents_num];
    
    iter = iter + 1;
    disp(['Iterations: ' num2str(iter)]);
%     mov(iter) = getframe(fig);

    %% Update the agent_array
    % [agent_array, switched_agents, non_stable_agent] = update_agent_array(agent_switch_p, agent_array, 'greedy', server_avail_capacity);
    % [agent_array, switched_agents, non_stable_agent] = update_agent_array(agent_switch_p, agent_array, 'random', server_avail_capacity);
    [agent_array, switched_agents, non_stable_agent] = update_agent_array(agent_switch_p, agent_array, 'greedy-rnd', server_avail_capacity);
end

f2 = figure(2);
title('SLA Violations Time Curve', 'FontSize', 16);
plot(violated_agents_curve(:, 2));
xlabel('The number of iterations');
ylabel('The number of SLA violations');
print(f2, '-dpng', [rst_file_name '-sla.png']);

save([rst_file_name '_sla.mat'], 'violated_agents_curve');

video_sessions = [];
for agent_ind = 1 : agent_num
    agent_sessions = total_violated_iterations(agent_ind, :);
    ind = find(abs(agent_sessions) > 0);
    
    while ~isempty(ind)
        session_end = min(ind(1) + life_duration, length(agent_sessions));
        session = agent_sessions(ind(1) : session_end);
        
        violation_period = sum(session == -1) ./ life_duration;
        
        video_sessions = [video_sessions; violation_period];
        ind = ind(ind > session_end);
    end
end

save([rst_file_name '_sessions.mat'], 'video_sessions');

f3 = figure(3);
title('The CDF of SLA violation time percentage.', 'FontSize', 16);
cdfplot(video_sessions);
xlabel('The Time Percentage of SLA violation'), ylabel('The percentage of agents');
print(f3, '-dpng', [rst_file_name '-cdf.png']);

% mmwrite('./rsts/agent_global.mp4', mov);
close(rstVideo);
