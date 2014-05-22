%% Oct. 29, 2013, Chen Wang
% Simulating the stability of agent based management system
% testRscUtl.m

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
agent_cap = zeros(agent_num, 1);
agent_alive = zeros(agent_num, 1);

per_agent_capacity = zeros(server_num, 1);

% Initialize image to be shown
death_color = [1 1 1];
bg = {'w','k'};
colors = distinguishable_colors(server_num, bg);
B = 30;
H = 30;
life_duration = 30;

sc_img = draw_agents(agent_array, agent_alive, colors, death_color, B, H);
cap_img = draw_agent_cap(agent_cap, B, H, max_agent_capacity);
agent_switch_p = (life_duration - agent_alive)./ life_duration;
p_img = draw_agent_cap(agent_switch_p, B, H, max_agent_capacity);
fig = figure(1);
set(fig, 'Position', [0 100 1400 400]);
fig_text = annotation('textbox', [0.5 0.05 0.3 0.1], 'String', 'Iteration: 0', 'FontSize', 24, 'FitBoxToText', 'on', 'EdgeColor', 'none');
subplot(1, 4, 1), imshow(sc_img), title('Server for each agent', 'FontSize', 16);
subplot(1, 4, 2), imshow(cap_img), title('Capacity for each agent', 'FontSize', 16);
subplot(1, 4, 3), imshow(p_img), title('Switching Probability for each agent', 'FontSize', 16);
subplot(1, 4, 4);
h4 = cdfplot(agent_cap); 
set(h4, 'linewidth', 2); 
title('The CDF of agent capacity', 'FontSize', 16), xlabel('The Capacity in agents'), ylabel('The cumulative probability');

%% Write Images to a Video
% Server video
rstVideo = VideoWriter('./rsts/agent_resource.mp4', 'MPEG-4');
rstVideo.FrameRate = 5;
open(rstVideo);
curFrame = getframe(fig);
writeVideo(rstVideo,curFrame);

%% Start iteration
iter = 1;

beta = 0.95;
lambda = beta * agent_num / life_duration;

% mov(iter) = getframe(fig);

while ((sum(agent_alive > 0) < agent_num * beta) || (sum(non_stable_agent) ~= 0)) && (iter < 200)
% while ((sum(agent_alive > 0) < agent_num * beta) || (sum(non_stable_agent) ~= 0))
    %% Update the birth and death of agent_alive
    agent_alive = update_agent_life(agent_alive, lambda, life_duration);
    agent_cap(agent_alive == 0) = 0;
    
    
    % Count the probability of agent switching
    agent_switch_p(agent_alive == 0) = 0;
    
    
    for i = 1 : server_num
        per_agent_capacity(i) = server_capacity / sum((agent_array == i) & (agent_alive > 0));
        
        if per_agent_capacity(i) > 1
            agent_cap((agent_array == i) & (agent_alive > 0)) = 1;
        else
            agent_cap((agent_array == i) & (agent_alive > 0)) = per_agent_capacity(i);
        end
        
        % If agent's capacity is bigger than its need, the agent does not
        % switch
        if per_agent_capacity(i) > th*max_agent_capacity
            agent_switch_p((agent_array) == i) = 0;
        else
            % Linear Decayed Probability
            % agent_switch_p((agent_array) == i) = (life_duration - agent_alive((agent_array) == i))./(2.*life_duration);
            
            % Exponentially Decayed Probability
            agent_switch_p((agent_array) == i) = 0.9.^agent_alive((agent_array) == i);
        end
    end
    
    non_stable_agent = (agent_switch_p > 0);
    
    % Show the updated image.
    sc_img = draw_agents(agent_array, agent_alive, colors, death_color, B, H);
    cap_img = draw_agent_cap(agent_cap, B, H, max_agent_capacity);
    p_img = draw_agent_cap(agent_switch_p, B, H, max_agent_capacity);

    fig = figure(1);
    set(fig, 'Position', [0 100 1400 400]);
    set(fig_text, 'String', ['Iteration: ' num2str(iter)]);
    subplot(1, 4, 1), imshow(sc_img), title('Server for each agent', 'FontSize', 16);
    subplot(1, 4, 2), imshow(cap_img), title('Capacity for each agent', 'FontSize', 16);
    subplot(1, 4, 3), imshow(p_img), title('Switching Probability for each agent', 'FontSize', 16);
    subplot(1, 4, 4);
    h4 = cdfplot(agent_cap); 
    set(h4, 'linewidth', 2);
    title('The CDF of agent capacity', 'FontSize', 16), xlabel('The Capacity in agents'), ylabel('The cumulative probability');
    
    curFrame = getframe(fig);
    writeVideo(rstVideo,curFrame);
    
    iter = iter + 1;
    disp(['Iterations: ' num2str(iter)]);
%     mov(iter) = getframe(fig);

    % Update the agent_array
    if sum(non_stable_agent) > 0
        agent_rand = agent_switch_p - rand(agent_num, 1) .* non_stable_agent;

        switched_agents = sum(agent_rand > 0);
        agent_array(agent_rand > 0) = randi(agent_candidates, switched_agents, 1);
    end
end

% mmwrite('./rsts/agent_global.mp4', mov);

close(rstVideo);
