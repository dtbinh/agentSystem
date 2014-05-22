function sc_img = draw_agents(agent_array, agent_alive, colors, death_color, B, H)
% draw a agent array into different color blocks in an image 
%
% sc_img = draw_agents(agent_array, agent_alive, B, H)
%
% Inputs: agent_array - The array of agents and its value indicates the 
%                       server id serving the agent 
%         agent_alive - The array of agents and its value indicates 
%                       whether the agent is alive (>0) or not ?0?.
%         colors - The color array denoting different servers.
%         death_color - The color that indicates the agent is not alive.
%         B - The pixel length of the block.
%         H - How many blocks the image has as height.
%
% Output: sc_img - the color block image that indicates which server serves
%                  which agent. Each block in the image is an agent. Each
%                  color indicates a unique server

% Authors: Chen Wang
% 28-Oct-13

agent_num = length(agent_array);
W = agent_num/H;
agent_img = reshape(agent_array, H, W);
alive_img = reshape(agent_alive, H, W);
img = zeros(H, W, 3);

for i = 1 : H
    for j = 1 : W
        if alive_img(i, j) == 0;
            img(i, j, :) = death_color;
        else
            img(i, j, :) = colors(agent_img(i, j), :);
        end
    end
end

sc_img = imresize(img, B, 'box');
