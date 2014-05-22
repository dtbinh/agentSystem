function [violated_agents_curve, video_sessions] = agentSystem(systemConfigure, runID)
% Run agent based load balancing system for large scale video on demand
% [violated_agents_curve, video_sessions] = agentSystem(systemConfigue, runID)
%
% Inputs: systemConfigure ---- The configuration object of the agent based
% system.
%         systemConfigure.server_num: the total number of servers in the
%         system.
%         systemConfigure.server_capacity: the total capacity each server
%         has.
%         systemConfigure.agent_num: the number of agents the system has.
%         systemConfigure.agent_candidates: the server candidates each
%         agent can connect to.
%         systemConfigure.agent_life_duration: the duration of life each
%         agent has.
%         systemConfigure.rsc_util: the average utilization rate in the 
%         steady period of the system.
%         systemConfigure.rst_dir: the directory where all results will be
%         saved.
%         systemConfigure.agent_typ: The type of agent that can be
%         "random", "greedy", "greedyRnd30" and "greedyRnd50".
%         systemConfigure.video_mode: 'on' or 'off'. 'on' denotes that the
%         iteration video demo is on.
%         systemConfigure.graph_mode: 'on' or 'off'. 'on' shows that the
%         result graphs are shown and saved to the systemConfigure.rst_dir.
%         systemConfigure.data_mode: 'on' or 'off'. 'on' denotes that the
%         data results are saved with runID to the systemConfigure.rst_dir.
%
%         method - It could be
%                  'random', in which agents randomely choose a server if
%                  its capacity requirement is not met.
%                  'greedy', in which agents greedily choose the server
%                  that has the largest available capacity.
%
% Output: agent_alive - Updated agent_alive array

% Author: Chen Wang
% 28-Oct-13

%% Initialize the variables retrieved from systemConfigure.
if exist('systemConfigure', 'var')
    server_num = systemConfigure.server_num; server_capacity = systemConfigure.server_capacity;
    agent_num = systemConfigure.agent_num; agent_candidates = systemConfigure.agent_candidates;
    th = systemConfigure.sla_th;
    video_mode = systemConfigure.video_mode;
    graph_mode = systemConfigure.graph_mode;
    data_mode = systemConfigure.data_mode;
    rst_dir = systemConfigure.rst_dir;
    life_duration = systemConfigure.agent_life_duration;
    agent_typ = systemConfigure.agent_typ;
    total_iter = systemConfigure.iter_num;
    beta = systemConfigure.rsc_util;
    alpha = systemConfigure.decay_factor;
else
    server_num = 12; server_capacity = 75;
    agent_num = 900; agent_candidates = 1 : server_num;
    th = 0.95;
    video_mode = 'on';
    graph_mode = 'on';
    data_mode = 'on';
    rst_dir = ['./' date];
    mkdir(rst_dir,'newFolder');
    life_duration = 50;
    agent_typ = 'random';
    total_iter = 500;
    beta = 0.9;
    alpha = 0.9;
end

if strcmp(agent_typ, 'greedyRnd')
    topN = systemConfigure.topN;
end
rst_file_name = [rst_dir agent_typ '_run' num2str(runID)];

%% Create a list of servers and clients
% nodes array stores the status of each server.
max_agent_capacity = server_num * server_capacity / agent_num;

% Initialize agent_matrix and randomly allocate each agent to one of the
% servers in agents' candidates.
agent_array = agent_candidates(randi(length(agent_candidates), agent_num, 1))';
agent_cap = zeros(agent_num, 1);
agent_alive = zeros(agent_num, 1);
server_avail_capacity = zeros(server_num, 1);

% Initialize image to be shown
if strcmp(video_mode, 'on')
    death_color = [1 1 1];
    bg = {'w','k'};
    colors = distinguishable_colors(server_num, bg);
    B = 30;
    H = 30;

    % Create images to show in video demon
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
    rstVideo = VideoWriter([rst_file_name '.mp4'], 'MPEG-4');
    rstVideo.FrameRate = 5;
    open(rstVideo);
    curFrame = getframe(fig);
    writeVideo(rstVideo,curFrame);
end

%% Start iteration
iter = 0;
lambda = beta * agent_num / life_duration;
violated_agents_curve = zeros(total_iter, 2);
total_violated_iterations = zeros(agent_num, total_iter);

while (iter < total_iter)
    
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
    
    if sum(agent_alive > 0) > 0
        violated_agents_ratio = sum(violated_agents) ./ sum(agent_alive > 0);
    else
        violated_agents_ratio = 0;
    end
    
    % Count the resource utilization rate
    res_rate = sum(agent_cap) ./ (server_capacity .* server_num);
    
    % Count the probability of agent switching
    agent_switch_p(agent_alive == 0) = 0;
    if violated_agents_ratio > 0
        % Linear Decayed Probability
        % agent_switch_p((agent_array) == i) = (life_duration - agent_alive((agent_array) == i))./(2.*life_duration);

        % Exponentially Decayed Probability
        agent_switch_p(violated_agents) = alpha.^agent_alive(violated_agents);
    else
        agent_switch_p = zeros(agent_num, 1);
    end
        
    
    
    %% Show the updated image.
    if strcmp(video_mode, 'on')
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
    end
    
    %% Count Statistics on this iteration
    violated_agents_curve(iter + 1, :) = [res_rate violated_agents_ratio];
    total_violated_iterations(:, iter + 1) = (agent_alive > 0).*1 - 2.*violated_agents;
    
    iter = iter + 1;
    disp(['Run: ' num2str(runID) ';  Iterations: ' num2str(iter)]);

    %% Update the agent_array
    switch agent_typ
        case 'random'
            [agent_array, ~, ~] = update_agent_array(agent_switch_p, agent_array, 'random', server_avail_capacity, agent_candidates);
        case 'greedy'
            [agent_array, ~, ~] = update_agent_array(agent_switch_p, agent_array, 'greedy', server_avail_capacity, agent_candidates);
        case 'greedyRnd'
            [agent_array, ~, ~] = update_agent_array(agent_switch_p, agent_array, 'greedyRnd', server_avail_capacity, agent_candidates, topN);
    end
end

%% Count all video sessions from all agents
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

%% Show and Print graphs
if strcmp(graph_mode, 'on')
    f2 = figure(2);
    title('SLA Violations Time Curve', 'FontSize', 16);
    plot(violated_agents_curve(:, 2));
    xlabel('The number of iterations');
    ylabel('The number of SLA violations');
    print(f2, '-dpng', [rst_file_name '-sla.png']);

    f3 = figure(3);
    title('The CDF of SLA violation time percentage.', 'FontSize', 16);
    cdfplot(video_sessions);
    xlabel('The Time Percentage of SLA violation'), ylabel('The percentage of agents');
    print(f3, '-dpng', [rst_file_name '-cdf.png']);

end

if strcmp(data_mode, 'on')
    save([rst_file_name '_sla.mat'], 'violated_agents_curve');
    save([rst_file_name '_sessions.mat'], 'video_sessions');
end

% mmwrite('./rsts/agent_global.mp4', mov);
if strcmp(video_mode, 'on')
    close(rstVideo);
end

end
