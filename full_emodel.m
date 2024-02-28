function [PEL1, PEL2] = full_emodel(WF,WT,EPL1,EPL2, ED, p1)
%[COST,WP,DF,FCASH,CRF,POWER,OPT,REP, TOTAL, ECO, WT] = ECONOMIC_MODEL(WF,WT,POWER,EP,LOAD,ED,p1)
% This program evaluates the full economic model,
% POWER, EPR and LOAD profile per hour:

% Inputs:
% Inputs:
% WF.- Wind Farm,
% WT.- Wind Turbine,
% PEL1:       Power, Energy Load profile from PML for its use in the economic model,
% PEL2:       Power, Energy and Load profile from GMTDH rates.
% ED.CC:      Capital Cost (USD),
% ED.OM:      Operation and Maintenance (USD),
% ED.PL:      Project Life,
% ED.R:       Real Interest,
% ED.CEL:     Incentives (USD/kW) for producing clean energy 
% p1.- Plot: 1='yes' or 0='no'

% Outputs:
% COST STRUCTURE
% COST.CC.DATA.- Capital Cost (USD)
% COST.OP.DATA.-Operating Costs(USD)
% COST.OMT.DATA.- Operation and Maintenance Costos (USD),
% WP.-      Wind Production Data Structure (kW/yr),
% DF.-      Discount Factor (DF),
% FCASH.-   Costs with Discount Factor (USD).
% CRF.-     Capital Recovery Factor.
% VA.-      Present Value,
% VAN.-     Net Present Value,
% POWER:    Electricity Production of a Single Turbine
% OPT:      Structure Data of Economic Results,
% REP:      Report Data,
% TOTAL:    Breakdown of Costs (USD),
% ECO:      Economic Results,
% WT:       Update WT.plot
%--------------------------------------------------------------------------
% Power profiles:
%--------------------------------------------------------------------------
P1=P.P1;
P2=P.P2;
P3=P.P3;
P4=P.P4; 
%--------------------------------------------------------------------------
% Conditioning inputs:
%--------------------------------------------------------------------------
LOAD2021=LOAD1;             % kW
% PML:
nyear=length(PML.Y);
PEL=[];PEL1.P1=[];PEL1.P2=[];PEL1.P3=[];PEL1.P4=[];
for i=1:4
   for j=1:nyear
       % PML:
       EPR=eval(strcat('PML.','Y',num2str(PML.Y(j),'%.0f'),'.yy'));
       % Power:
       P=eval(strcat('P',num2str(i,'%.0f')));
       % Power, Energy prices and Load profiles:
       [pel] = power_hour(P,EPR,LOAD2021);
       m1=strcat('PEL1',num2str(i,'%.0f'),'_',num2str(PML.Y(j),'%.0f'));
       m2=strcat('PEL1',num2str(i,'%.0f'));
       yy=strcat('Y',num2str(PML.Y(j),'%.0f'));
       eval([m2 '=m2;'])
       if i==1
        PEL1.P1= setfield(PEL1.P1,yy,pel);                    % Power profile  
       end
       if i==2
        PEL1.P2= setfield(PEL1.P2,yy,pel);                    % Power profile  
       end
       if i==3
        PEL1.P3= setfield(PEL1.P3,yy,pel);                    % Power profile  
       end
       if i==4
        PEL1.P4= setfield(PEL1.P4,yy,pel);                    % Power profile  
       end
       eval([m2 '=PEL;'])
   end
end
%--------------------------------------------------------------------------
% GMDTH:
%--------------------------------------------------------------------------
LOADGM21=LOAD2;
nyear=length(GMDTH.Y);
PEL2=[];PEL2.P1=[];PEL2.P2=[];PEL2.P3=[];PEL2.P4=[];
for i=1:4
   for j=1:nyear
       % PML:
       EPRGM=eval(strcat('GMDTH.','Y',num2str(GMDTH.Y(j),'%.0f'),'.PR'));
       % Power:
       P=eval(strcat('P',num2str(i,'%.0f')));
       % Power, Energy prices and Load profiles:
       [pel] = power_hour(P,EPRGM,LOADGM21);
       m1=strcat('PEL2',num2str(i,'%.0f'),'_',num2str(GMDTH.Y(j),'%.0f'));
       m2=strcat('PEL2',num2str(i,'%.0f'));
       yy=strcat('Y',num2str(GMDTH.Y(j),'%.0f'));
       eval([m2 '=m2;'])
       %PEL2= setfield(PEL2,yy,pel);                         % Power profile
       if i==1
        PEL2.P1= setfield(PEL2.P1,yy,pel);                    % Power profile  
       end
       if i==2
        PEL2.P2= setfield(PEL2.P2,yy,pel);                    % Power profile  
       end
       if i==3
        PEL2.P3= setfield(PEL2.P3,yy,pel);                    % Power profile  
       end
       if i==4
        PEL2.P4= setfield(PEL2.P4,yy,pel);                    % Power profile  
       end
   end
       eval([m2 '=PEL2;'])
end