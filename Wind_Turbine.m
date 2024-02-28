function [WT] = Wind_Turbine()
% Function Wind Turbine
% This program describes the wind turbine features:

% Inputs:

% Outputs:
% Turbine Type:
WT.Type='V150-6.0MW';
% Rated Power (kW):
WT.P= 6e3;                  % kW
% Number of phases:
WT.Nph=3;                   %
%-----------------------------------------------
% Operational Data:
%-----------------------------------------------
% CUT_IN:
WT.CUT_IN=3;                % m/s
% CUT_OUT:
WT.CUT_OUT=25;              % m/s
% Rate wind speed:
WT.RWS=12;                  % m/s
% Designed for wind class:
WT.CLASS='IECS';
% NOisee at hub heigth:
WR.NOISE=104.9;             % dB
%-----------------------------------------------
% Rotor:
%-----------------------------------------------
% Rotor Diameter (m):
WT.D=150;                   % m
WT.Speed='Variable';        % m/s
WT.PReg='Full span pitch';  %
WT.TAngle='6°';              % Degrees
WT.Blade='Glass fiber reinforced epoxy';
%-----------------------------------------------
% Power Converter:
%-----------------------------------------------
WT.CONVETER='Voltage Source Inverter';
WT.VLL=36;                   % kV
WT.GRID='AC-DC-AC';
%-----------------------------------------------
% Tower:
%-----------------------------------------------
WT.TOWER='Steel Tubular';
% Height of hub: [80 to 140 m]
WT.Hub= 105;                 % m
%-----------------------------------------------
% Masses:
%-----------------------------------------------
WT.MASS.T=281;               % TON
WT.MASS.ROTOR=97;            % TON
WT.MASS.GENERATOR=137;       % TON
WT.MASS.NACELLE=47;          % TON
%----------------------------------------------
% Pcurve:
%----------------------------------------------
WT.Wind=[0:1:WT.CUT_OUT];          % m/s
% Initialize Power Curve Data:
WT.Power=zeros(1,WT.CUT_OUT+1);      % W
% Power points:
Pstart=0;                 % kW
Prate=WT.P;               % kW
Pstop=WT.P;               % kW
      %
% Slop between Vstop and Vrate:
m= (Prate-Pstart)/(WT.RWS-WT.CUT_IN); %
% Power Curve Data:
% Zeros
for i=1:WT.CUT_OUT+1
    if i>=WT.RWS+1
        WT.Power(i)=Prate;     % kW
    elseif i>=WT.CUT_IN+1 & i<WT.RWS+1
        WT.Power(i)= m*(i-WT.CUT_IN)+Pstart;   
    end
end
% WT.Power(4)=100;             % kW
% WT.Power(5)=250;             % kW
% WT.Power(6)=500;             % kW
% WT.Power(7)=750;             % kW
% WT.Power(8)=1100;            % kW
% WT.Power(9)=1500;            % kW
% WT.Power(10)=2000;           % kW
% WT.Power(11)=2400;           % kW
% WT.Power(12)=2650;           % kW
% WT.Power(13)=2850;           % kW
% WT.Power(14)=2950;           % kW
% UPDATE POWER CURVE:
WT.Power(4)=125;               % kW
WT.Power(5)=500;               % kW
WT.Power(6)=1000;               % kW
WT.Power(7)=1600;              % kW
WT.Power(8)=2500;              % kW
WT.Power(9)=3500;              % kW
WT.Power(10)=4700;             % kW
WT.Power(11)=5500;             % kW
% WT.Power(12)=4400;             % kW
% WT.Power(13)=4700;             % kW
%WT.Power(12)=3750;           % kW
%WT.Power(13)=4375;           % kW
%WT.Power(14)=5000;           % kW
