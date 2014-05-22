function agent_alive = update_agent_life(agent_alive, lambda, life_duration)
% update whether an agent is alive for agent_alive array
%
% agent_alive = update_agent_life(agent_alive, lambda, life_duration)
%
% Inputs: agent_alive - The array of agents and its value indicates 
%                       whether the agent is alive (>0) or not ?0). Its
%                       value indicates how long the agent has been alive.
%         lambda - The average number of occurance during an iteration
%         life_duration - The duration of an agent which can be alive
%
% Output: agent_alive - Updated agent_alive array

% Author: Chen Wang
% 28-Oct-13

p_birth = poissrnd(lambda);

% Add 1 period of life for all alive agents
agent_alive(agent_alive > 0) = agent_alive(agent_alive > 0) + 1;

% Label those who have longer duration than life_duration as dead agents.
agent_alive(agent_alive > life_duration) = 0;

% Give birth to new agents according to poisson distribution.
agent_dead = find(agent_alive == 0);
if (length(agent_dead) < p_birth) && (~isempty(agent_dead))
    agent_alive(agent_dead) = 1;
elseif length(agent_dead) >= p_birth
    agent_birth = randsample(agent_dead, p_birth);
    agent_alive(agent_birth) = 1;
end

