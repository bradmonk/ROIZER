%###############################################################
%###############################################################
%                                                              |
%--               ROIpostprocessing                           --
%                                                              |
%###############################################################
%###############################################################
clc; close all; clear;

P.home = pwd;
if ~any(regexp(P.home,'ROIZER') > 0)
disp(['Run this code from the ROIfinder directory; '...
'your current working directory is instead:'])
disp(P.home);
P.home='/Users/bradleymonk/Documents/MATLAB/GIT/ROIZER';
cd(P.home)
end
P.funs  = [P.home filesep 'datasets'];
P.data  = [P.home filesep 'functions'];
addpath(join(string(struct2cell(P)),':',1))





%###############################################################
%% SELECT A TIFF STACK AND GET INFO
%###############################################################

[PIX] = getIMpath();

clearvars -except PIX

head(T)



% 20180926_2p	
% TSeries-09262018-slice1baseline0-002    Baseline	cLH
% TSeries-09262018-slice1baseline15-003   Baseline + 15min	cLH
% TSeries-09262018-slice1drugs15-004      Baseline + 15 min + 15 min 1uM Naltrexone+10uM Ket	cLH





























