function [agent_array, switched_agents, non_stable_agent] = update_agent_array(agent_switch_p, agent_array, method, server_avail_capacity, agent_candidates, topN)
% update the agent_array and perform switching for agents whose capacity
% requirements are not met
%
% [agent_array, switched_agents, non_stable_agent] = update_agent_array(agent_switch_p, agent_array, method, server_ave_capacity)
%
% Inputs: agent_switch_p - The agent switching probabilities.
%         agent_array - The existing server node agents are connection to.
%         method - It could be
%                  'random', in which agents randomely choose a server if
%                  its capacity requirement is not met.
%                  'greedy', in which agents greedily choose the server
%                  that has the largest available capacity.
%
% Output: agent_alive - Updated agent_alive array

% Author: Chen Wang
% 28-Oct-13

agent_num = length(agent_array);
non_stable_agent = (agent_switch_p > 0);

if ~exist('method', 'var')
    method = 'random';
end

if (nargin >= 3) && strcmp(method, 'random') && exist('server_avail_capacity', 'var')
    if ~exist('agent_candidates', 'var')
        agent_candidates = 1 : length(server_avail_capacity);
    end
    
    if sum(non_stable_agent) > 0
        agent_rand = agent_switch_p - rand(agent_num, 1) .* non_stable_agent;

        switched_agents = sum(agent_rand > 0);
        agent_array(agent_rand > 0) = agent_candidates(randi(length(agent_candidates), switched_agents, 1));
    else
        switched_agents = 0;
    end

elseif strcmp(method, 'greedy') && exist('server_avail_capacity', 'var')
    
    if sum(non_stable_agent) > 0
        agent_rand = agent_switch_p - rand(agent_num, 1) .* non_stable_agent;

        switched_agents = sum(agent_rand > 0);
        
        [~, server_ind_max] = max(server_avail_capacity);
        agent_array(agent_rand > 0) = agent_candidates(server_ind_max);
    else
        switched_agents = 0;
    end
elseif strcmp(method, 'greedyRnd') && exist('server_avail_capacity', 'var') && exist('topN', 'var')
    % Add the randomness in greedy agents
    if sum(non_stable_agent) > 0
        agent_rand = agent_switch_p - rand(agent_num, 1) .* non_stable_agent;

        switched_agents = sum(agent_rand > 0);
        
        [~, server_ind_sort] = sort(server_avail_capacity, 'descend');
        
        agent_array(agent_rand > 0) = agent_candidates(server_ind_sort(randi(topN, switched_agents, 1)));
    else
        switched_agents = 0;
    end
end