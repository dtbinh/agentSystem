%% Oct. 28, 2013, Chen Wang
% Testing the birth-death process generation function
% testBDProcess.m

%% Logistics
clear all;
close all;
clc;

npoints = 900;
[tjump, state] = birthdeath(npoints);