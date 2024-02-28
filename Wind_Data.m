function [WIND] = Wind_Data(WT)
% Function Wind Data
% This program characterize wind data:

% Inputs:
% WT.- Wind Turbine Data

% Outputs:
% Wind Database:
% WData=xlsread('LV2006C.csv');
% %WData=xlsread('SANCHEZ_MAGALLANES.csv');
% % Speeds:
% % 15 m:
% WIND.V15.DATA=WData(:,3);
% % 32 m
% WIND.V32.DATA=WData(:,7);
% % Day:
% d = 100;
% MM = mod(WData(:,2),d);                % Hour
% HH = (WData(:,2) - MM)/d;              % Minute
% L=length(WData(:,1));
% YY=ones(L,1)*2006;
% WIND.TIME.YEAR=YY;
% WIND.TIME.MONTH= month(WData(:,1));
% WIND.TIME.DAY=WData(:,1);
% WIND.TIME.HOUR=HH;
% WIND.TIME.MINUTE=MM;
% 
% DATE=[WIND.TIME.YEAR WIND.TIME.MONTH WIND.TIME.DAY WIND.TIME.HOUR WIND.TIME.MINUTE];
load('WDATA.mat');
WIND=wind;
WIND.V50.DATA=WIND.w.W50;
WIND.V10.DATA=WIND.w.W10;
WIND.V93.DATA=WIND.w.W93;
%WIND.V20.DATA=WIND.w.W20;
% Directions:
%WIND.D80.DATA=WIND.D80.DATA;
%WIND.D78.DATA=WIND.d.D78;
%WIND.D58.DATA=WIND.d.D58;
%WIND.D20.DATA=WIND.D20.DATA;
% Probility Distribution Function (PDF):
VCUT=WT.CUT_OUT;                       % m/s
% V50 (m/s):
[f F v NWS]=wind_distribution(WIND.V50.DATA,VCUT);
WIND.V50.f=f;
WIND.V50.F=F;
WIND.V50.V=v;
WIND.V50.NWS=NWS;

% V10 (m/s):
[f F v NWS]=wind_distribution(WIND.V10.DATA,VCUT);
WIND.V10.f=f;
WIND.V10.F=F;
WIND.V10.V=v;
WIND.V10.NWS=NWS;

% V93 (m/s):
[f F v NWS]=wind_distribution(WIND.V93.DATA,VCUT);
WIND.V93.f=f;
WIND.V93.F=F;
WIND.V93.V=v;
WIND.V93.NWS=NWS;

% V20 (m/s):
% [f F v NWS]=wind_distribution(WIND.V20.DATA,VCUT);
% WIND.V20.f=f;
% WIND.V20.F=F;
% WIND.V20.V=v;
% WIND.V20.NWS=NWS;

% Logarithmic Law:
VM50=nanmean(WIND.V50.DATA);   % m/s
VM10=nanmean(WIND.V10.DATA);   % m/s
Z=10;                          % m
Zr=50;                         % m
alfa=log(VM10/VM50)/log(Z/Zr);
%alfa=log(VM15/VM32)/log(Zr/Z);
WIND.ZR=Zr;                    % m
WIND.ALFA=alfa;                % Dimenssionless
% Exponential Law:
%alfa=0.2;
Z0=exp(log(15.25)-1/alfa);     % m
WIND.Z0=Z0;
% Maximum Likelihood Estimation:
% V50 (m/s): Weibull Data;
I50=find(WIND.V50.DATA>0);
[k,c, iter, K]= MLE(WIND.V50.DATA(I50));
WIND.W50.k=k;
WIND.W50.c=c;
WIND.W50.iter=iter;
WIND.W50.K=K;

% V10 (m/s):
I10=find(WIND.V10.DATA>0);
[k,c, N, K]= MLE(WIND.V10.DATA(I10));
WIND.W10.k=k;
WIND.W10.c=c;
WIND.W10.iter=iter;
WIND.W10.K=K;
% V40 (m/s):
I50=find(WIND.V50.DATA>0);
[k,c, N, K]= MLE(WIND.V50.DATA(I50));
WIND.W50.k=k;
WIND.W50.c=c;
WIND.W50.iter=iter;
WIND.W50.K=K;

% V93 (m/s):
I93=find(WIND.V93.DATA>0);
[k,c, N, K]= MLE(WIND.V93.DATA(I93));
WIND.W93.k=k;
WIND.W93.c=c;
WIND.W93.iter=iter;
WIND.W93.K=K;