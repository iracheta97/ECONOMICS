function [WF] = WFARM(WT,WIND,T,PF,A,rhocu,CP)
% Function WFARM
% This program describes the wind turbine layout, and
% provide information about the electric circuits

% Inputs:
% WF.- WIND FARM
% WIND.- WIND
% T.- WIND FARM LAYOUT
% PF.- POWER FACTOR
% A.- CONDUCTOR AREAS
% rhocu.- Copper resistivity
% CP.- FACTOR DE PLANTA (PLANT FACTOR)
% Outputs:
% Type of installation: Off-shore or On-shore:
WF.Type='Off-shore';
% Number of Wind Turbines:
WF.N=10;                        % Wind Turbines
% Number of circuits:
WF.NC=2;
% Number of WT's per circuit:
WF.WTC=zeros(1,WF.NC);
WF.WTC=[5 5];
% Power per circuit:
WC.PC=WT.P*WF.WTC;               % Watts
% Wind Farm Power:
WF.P=sum(WC.PC);                 % Watts
% Wind Layout (D):
WL=max(WF.WTC);                  % m
% L=zeros(WF.NC,WL);               % m
% for i=1:WF.NC
%     for j=1:WL
%          if  j==1
%             L(i,j)=SE;
%          else
%             L(i,j)=WT.D*x;
%          end
%     end
% end
WF.L=T;                             % m
% Resistance (R in Ohms):
% R=zeros(WF.NC,WL);                               % m
% for i=1:WF.NC
%     for j=1:WL
%          if j==1
%             R(i,j)=SE*CABLE.Rac/1e3;        % Ohms/m
%          else
%             R(i,j)=WT.D*x*CABLE.Rac/1e3;    % Ohms/m
%          end
%     end
% end
R= rhocu*1e6*T./(A);                           % Ohms/m
WF.R=R;                                        % Ohms/m
% Power Losses:
N=zeros(WF.NC,WL);                                 % m
for i=1:WF.NC
    N(i,1:WF.WTC(i))=WF.WTC(i):-1:1;
end
% N2*R:
% Considering n generators:
NRL=N.*R;
WF.NRL=NRL;                                       % Ohms
% Joule Power Losses:
WF.P=zeros(WF.NC,WL);                             % m
WF.I=zeros(WF.NC,WL);                             % m
WF.POWER=[];WF.I=[];WF.PLOSS=[];WF.PLP=[];WF.DV=[];WF.PDV=[];
for i=1:WF.NC
        POWER(i,:)=(WT.P).*N(i,:)/1e3;                                       % MW
        I(i,:)=(POWER(i,:)*1e3/(sqrt(3)*WT.VLL*PF));                         % A
        %PLOSS(i,:)=(power(WT.P/(WT.VLL*PF),2).*NRL(i,:)/1E6);               % MW
        PLOSS(i,:)=WT.Nph*power(I(i,:),2).*NRL(i,:)/1E6;                     % MW
        PLP(i,:)=100*PLOSS(i,:)./POWER(i,:);                                 % %
end
% TOTAL POWER:
WF.PTOT=sum(sum(POWER));                       % kW
% DV: Drop Voltage:
DV=I.*WF.R;                                    % DV
% PDV: Percentage of Drop Voltage:
PDV=100*mean(DV(:,1)/(WT.VLL*1e3));
% RESULTS:
WF.POWER=struct('DATA',POWER,'UNITS','MW');
WF.I=struct('DATA',I,'UNITS','A');
WF.DV=struct('DATA',DV,'UNITS','V');
WF.PLOSS=struct('DATA',PLOSS,'UNITS','MW');
WF.PLP=struct('DATA',PLP,'UNITS','%');
WF.PDV=struct('DATA',PDV,'UNITS','%');

% POWER:
% EXTRAPOLATION OF WIND SPEED AT HUB HEIGTH: 80 m
Z=WT.Hub;                                      % m
alfa=WIND.ALFA;                                % Dimenssionless
Zr=WIND.ZR;
Vr=WIND.V50.DATA;                              % m/s
Vhub=Vr*power(Z/Zr,alfa);                      % m/s
WF.Vhub=Vhub;                                  % m/s
% Statistical Data:
vcut=WT.CUT_OUT;
[f F vv NWS]=wind_distribution(Vhub,vcut);
WF.STAT=struct('f',f,'F',F,'vv',vv,'NWS',NWS);
% Vhub (m/s): Weibull Data;
I=find(Vhub>0);
[k,c, iter, K]= MLE(Vhub(I));
WF.WIND=struct('k',k,'c',c,'iter',iter,'K',K);
% Measurement at hub heigth:
% Power Curve:
Pcurve=WT.Power;                               % kW
% Determination of Hours:
hours=8760*f*CP;                               % hours
% Power Values between Vstart and Vrate:
% Annual Energy Production (GWh):
WF.EAP=[];
EAP=WF.N*sum(Pcurve.*hours/1E6);                                                              % GWh
WF.EAP= setfield(WF.EAP,'DATA',EAP);
WF.EAP= setfield(WF.EAP,'UNITS','GWh');
% Annual Loss (GWh):
WF.EPL=[];WF.PEPL=[];
% Constant:
 for i=1:WF.NC
     for j=1:vcut
      CTE(i,j)=power(Pcurve(j)./(WT.VLL*PF),2).*sum(NRL(i,:).*N(i,:)).*hours(j)/1E9;             % GWh
     end
 end
EPL=sum(sum(CTE));
WF.EPL= setfield(WF.EPL,'DATA',EPL);
WF.EPL= setfield(WF.EPL,'UNITS','GWh');
% Percentage of Energy Power Loss (%):
PEPL=100*EPL/EAP;
WF.PEPL= setfield(WF.PEPL,'DATA',PEPL);
WF.PEPL= setfield(WF.PEPL,'UNITS','%');