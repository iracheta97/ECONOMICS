function [WE] = Wind_Economy(WT)

% This program evaluates the economy of a wind farm:

% Inputs:
% Wind Farm
%WF.- Wind Farm Data;

% Outputs:
% Cash Flow

% Wind Turbine Costs ($ USD/kW):
% Capital Cost ($ USD/kW):
WE.Turbine.CC= -1600*WF.N;            
WE.Turbine=struct('DATA',POWER,'UNITS','USD/kW');