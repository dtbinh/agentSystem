%% Oct. 17, 2013, Chen Wang
% Simulating the agents that arrives the system in continuous time and
% greedily choose the server whenever it is needed.
% testContinuousAgent.m

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