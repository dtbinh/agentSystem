%% Oct. 17, 2013, Chen Wang
% Simulating the stability of agent based management system
% testAgent.m

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
agent_conn = 4;

agent_group_num = server_num / agent_conn;
agent_group = agent_num / agent_group_num;
ave_agent_capacity = server_num * server_capacity / agent_num;
th = 0.95;

%% Initialize agent_matrix and randomly allocate each agent to one of the
% servers in agents' candidates.
agent_matrix = zeros(agent_group, agent_group_num);

for col = 0 : agent_group_num - 1
    agent_matrix(:, col + 1) = randi(agent_conn, agent_group, 1) + col*agent_conn;
end

non_stable = agent_num;
per_agent_capacity = zeros(server_num, 1);

agent_array = agent_matrix(:);

% Initialize image to be shown
colors = distinguishable_colors(server_num);
B = 10;
H = 30;
W = agent_num/30;
agent_img = reshape(agent_array, H, W);
img = zeros(H, W, 3);

for i = 1 : H
    for j = 1 : W
        img(i, j, :) = colors(agent_img(i, j), :);
    end
end

sc_img = imresize(img, B, 'box');
fig = figure(1);
imshow(sc_img);

% Write Images to a Video
rstVideo = VideoWriter('./rsts/agent_region.mp4', 'MPEG-4');
rstVideo.FrameRate = 25;
open(rstVideo);
curFrame = getframe(fig);
writeVideo(rstVideo,curFrame);

iter = 1;
while (non_stable > 0) && (iter <= 500)
    
    non_stable_agent = zeros(agent_num, 1);
    for i = 1 : server_num
        per_agent_capacity(i) = server_capacity / sum(agent_array == i);
        
        if per_agent_capacity(i) < th*ave_agent_capacity
            non_stable_agent((agent_array) == i) = 1;
        end
    end
    
    non_stable = sum(non_stable_agent);
    
    % Update the agent_array
    agent_matrix = reshape(agent_array, agent_group, agent_group_num);
    non_stable_agent_mat = reshape(non_stable_agent, agent_group, agent_group_num);
    
    for col = 0 : agent_group_num - 1
        agent_col = agent_matrix(:, col + 1);
        non_stable_agent_col = non_stable_agent_mat(:, col + 1);
        agent_col(non_stable_agent_col == 1) = randi(agent_conn, sum(non_stable_agent_col), 1) + col*agent_conn;
        agent_matrix(:, col + 1) = agent_col;
    end
    
    agent_array = agent_matrix(:);
    
    % Show the updated image.
    
    agent_img = reshape(agent_array, H, W);
    img = zeros(H, W, 3);

    for i = 1 : H
        for j = 1 : W
            img(i, j, :) = colors(agent_img(i, j), :);
        end
    end

    sc_img = imresize(img, B, 'box');
    fig = figure(1);
    imshow(sc_img);
    
    curFrame = getframe(fig);
    writeVideo(rstVideo,curFrame);
    
    iter = iter + 1;
    disp(['Iterations: ' num2str(iter)]);
end

close(rstVideo);