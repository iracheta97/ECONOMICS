% This program calculate the Joule losses of underwater cables
% in a off-shore Wind Farm

% Created by: Dr. Reynaldo Iracheta Cortez
% Date: 2/April/2019

clc;
clear;
%--------------------------------------------------------------------------
% Wind Turbine Data:
%--------------------------------------------------------------------------
load('WT_E200L');        % kW
% Reset plots:
WT.plot=0;
WTE200=WT;
%--------------------------------------------------------------------------
% Electricity Prices:
%--------------------------------------------------------------------------
%load('EPRICE_GMDTH.mat');         % USD/kW
load('PML');                       % USD/kWh
% PR2021=PML.Y2021.yy;
% PR2022=PML.Y2022.yy;
% EPR2021=PR2021;
% EPR2022=PR2022;
load('GDMTH');
% GM2021=GDMTH.Y2021.PR;
% GM2022=GDMTH.Y2022.PR;
% EPRGM21=GM2021(:,1);                 % USD/kW
% EPRGM22=GM2022(:,1);
%--------------------------------------------------------------------------
% Load data:
%--------------------------------------------------------------------------
% % PML:
% LOAD2021=0*EPR2021;                  % kW
% LOAD2022=0*EPR2022;                  % kW
% % GMDTH:
% LOADGM21=0*EPRGM21;                  % kW
% LOADGM22=0*EPRGM22;                  % kW
%--------------------------------------------------------------------------
% Wind Farm Data:
%--------------------------------------------------------------------------
load('WF1L');
WF1=WF1;                           % CERTE
load('WF2L');
WF2=WF2;                           % MERRA-2
load('WF3L');
WF3=WF3;                           % ERA-5
load('WF4L');
WF4=WF4;                           % WTK
%--------------------------------------------------------------------------
% Annual Energy Production (AEP)-(kWh):
%--------------------------------------------------------------------------
%load('POWER');           % kW
load('P1L.mat');          % MWh     % CERTE
load('P2L.mat');          % MWh     % MERRA-2
load('P3L.mat');          % MWh     % ERA-5
load('P4L.mat');          % MWh     % WTK
P=[];
P.P1=P1;P.P2=P2;P.P3=P3;P.P4=P4; 
%--------------------------------------------------------------------------
% Conditioning inputs:
%--------------------------------------------------------------------------
% 1 refers to PML,
% 2 refers to GMDTH.
load UNISTMO.mat
% LOADL=LOAD.Data;          % kW
% LOADG=LOAD.GEN.PNET1;     % kW
% LOAD1=LOADL;
% LOAD2=LOADG;
%[PEL1, PEL2] = condition_inputs(P, PML,GDMTH,LOAD1, LOAD2);
[PEL1, PEL2] = condition_inputs(P,PML,GDMTH,LOAD);
%--------------------------------------------------------------------------
% Economic Data:
%--------------------------------------------------------------------------
% Wind Production:
% Capital Cost:
CC=2200;               % USD/kW
% Operation & Maintenance:
OM=2;                  % Percentage
% Project Life:
PL=20;                 % Years
% Real interest:
R=4;                  % Percentage
% Simulation Case:
% 1: Only Power Network
% 2: Power Network + 1 Turbine
WF=WF1;
CASE=WF.N+1;
% Cash Flow: (1: Nominal; 2: Discounted):
CF=1;
% Summary Costs: (1:Present Net, 2: Annualized);
SC=2;
% Categorize: (1: By Component, 2: By Cost Type:
CAT=2;
% Incentives:
CEL=0.01;               % USD/kW
% Contract type:
% 1: Total Sell,
% 2: Net billing,
% 3: Net metering.
CT=2;
% Electricity rate for total sell:
% 1: PML;
% 2: GDMTH.
ERATE=2;
% Type of load:
% 1: Installation (UNISTMO),
% 2: Load = Generation
LL=2;
% Load percentage:
PLOAD=30;               % [%]
% Plot:
p1=1;                   % 1 is YES, 0 is NO
% Excel file:
p2=0;                   % 1 is file, 0 is not file
% Structure Data:
ED=[];
ED=setfield(ED,'CC',CC);                    % Capital Cost (USD/kW)
ED=setfield(ED,'OM',OM);                    % O&M Cost (USD/kW),
ED=setfield(ED,'PL',PL);                    % Project Life (years),
ED=setfield(ED,'R',R);                      % Real Interest (%),
ED=setfield(ED,'CASE',CASE);                % Simulation Case,
ED=setfield(ED,'CF',CF);                    % Cash Flow (USD) {1-2},
ED=setfield(ED,'SC',SC);                 	% Summary Cost (USD) {1-2},
ED=setfield(ED,'CAT',CAT);                 	% Categoriza {1-2},
ED=setfield(ED,'CEL',CEL);                 	% Incentives (USD/kW),
ED=setfield(ED,'CT',CT);                 	% Contract type,
ED=setfield(ED,'ERATE',ERATE);              % 1: PML, 2:GDMTH,
ED=setfield(ED,'LOAD',LL);                 	% Load Type,
ED=setfield(ED,'PLOAD',PLOAD);                 % PLOAD: Percentage load,
ED=setfield(ED,'P1',p1);                 	% 1 is for PLOT, 2 is for not plotting,
ED=setfield(ED,'P2',p2);                 	% 1 is for an EXCEL file, 2 is for not an EXCEL file,
%--------------------------------------------------------------------------
% Economic Model: March 6th, 2023
%--------------------------------------------------------------------------
% Inputs:
% WF: Wind farm,
% WT: Wind turbine,
% PGROSS: Power Gross,
% EPR: Electricity prices (USD/kW),
% LOAD: Load profile,
% ED: Estructure Data,
% p1: Plot yes or not?

% Economic Model:
PEL=PEL1.P1.Y2022;
%[REA, WT] = ECONOMIC_MODEL(WF,WT,PEL,ED);
[REA, WT] = ECONOMIC_MODEL2(WF,WT,PEL,ED);
%[COST,WP,DF,FCASH,CRF,POWER,OPT,REP, TOTAL, ECO,WTE200] = ECONOMIC_MODEL(WF1,WTE200,PGROSS1,EPR1,LOAD1,ED,0);            % USD
%--------------------------------------------------------------------------
% Economic Analysis for all wheather stations:
%--------------------------------------------------------------------------
% ED.P1=0;
% % Total sell of energy:
% ED.CT=1;
% [RWS, WT] = APLT_EMODEL(WF,WT,PEL1,PEL2,ED);
%--------------------------------------------------------------------------
% Economic Analyisis with Load:
%--------------------------------------------------------------------------
% The function ECONOMIC_MODEL2 is designed to work with LOAD and two prices
% of electricity:
% % % 1.- To buy electricity:
% BUY=PEL2.P1.Y2022;              % GDMTH
% % % 2.- To sell electricity.
% SELL=PEL1.P1.Y2022;             % PML
% % % Matrix of prices of electricity:
% % Plot:
% ED.P1=0;
% % Load:
% BUY.LOAD=0.5*BUY.NET;
%%[REA2, WT] = ECONOMIC_MODEL2(WF,WT,PEL,ED);
%--------------------------------------------------------------------------
% Plots of Economic model:
%--------------------------------------------------------------------------
%[WTE200] = PLOT_FCASH(WTE200,REP3,REP4,1);
%--------------------------------------------------------------------------
% Sensitivity analysis:
%--------------------------------------------------------------------------
% Variable Load:
% 1: Total sell of energy,
% 2: Net billing
% 3: Net metering
% ED.CT=1;
% Variable capital costs:
[RSA,WT]=SENSITIVITY(WF,WT,PEL,ED);
% Variable Operation and Maintenance costs:
[RSAOM,WT]=SENSITIVITY_OM(WF,WT,PEL,ED);
% Variable Interest rate:
[RSAR,WT]=SENSITIVITY_R(WF,WT,PEL,ED);
% Variable Load:
% 2: Net billing
% 3: Net metering
% ED.CT=2;
% % Type of load:
% % 1: Installation (UNISTMO),
% % 2: Load = Generation
% ED.LL=2;
[RSAL,WT]=SENSITIVITY_LOAD(WF,WT,PEL,ED);