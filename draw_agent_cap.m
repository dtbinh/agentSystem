function cap_img = draw_agent_cap(agent_cap, B, H, max_agent_capacity)
% draw a agent capacity array into different gray level blocks in an image 
%
% cap_img = draw_agent_cap(agent_cap, B, H)
%
% Inputs: agent_cap - The capacity array of agents and its value indicates the 
%                       capacity this agent gets from server 
%         B - The pixel length of the block.
%         H - How many blocks the image has as height.
%         max_agent_capacity - The maximum agent capacity an agent can use.
%
% Output: cap_img - the gray image that indicates how much capacity each agent
%                   gets. Each block in the image is an agent. Each
%                  gray level indicates an agent capacity.

% Authors: Chen Wang
% 28-Oct-13

agent_num = length(agent_cap);

% Cap the capacity if it is greater than 1.
agent_cap(agent_cap > max_agent_capacity) = max_agent_capacity;

W = agent_num/H;
agent_img = reshape(agent_cap, H, W);
cap_img = imresize(agent_img, B, 'box');
