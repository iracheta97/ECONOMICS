function [RWS, WT] = APLT_EMODEL(WF,WT,PEL1,PEL2,ED)

% This program resolves the economic model of the following cases:
% Electricity prices for all:
% 1) PML prices,
% 2) GMDTH prices,
% Wheather stations:
% a) Certe, b) Merra, c) Era, d) WindToolKit (WTK).
% 
% Inputs:
% WF:          Wind Farm data,
% WT:          Wind Turbine data,
% PEL1:        Structure of power profile for PML electricity prices,
% PEL2:        Structure of power profile for GMDTH electricity prices,
% PEL.GROSS:   Annual Gross Energy profile (kW) (8760 Data) Single turbine,
% PEL.NET:     Annual Net Energy profile (kW) (8760 Data) Single turbine,
% PEL.EPR:     Annual Electricity price profile (USD/kW) (8760 Data),
% PEL.LOAD:    Annual Load Profile in kW (8760 Data),
% Cost analysis:
% ED.CC:    Capital Cost (USD),
% ED.OM:    Operation and Maintenance (USD),
% ED.PL:    Project Life,
% ED.R:     Real Interest,
% ED.CEL:   Incentive rate (USD/kW).
% p1.- Plot: 1='yes' or 0='no'
% pex.- Generate excel file: 1='yes' or 0='no'

% Outputs:
% Economic results of all wheather stations and years.
% RWS.-     Economic results of all wheather stations
%--------------------------------------------------------------------------
% Pre-processing data:
%--------------------------------------------------------------------------
% Number of years:
NY1=PEL1.nyear;         % PML
NY2=PEL2.nyear;         % GMTDH
% Numer of weather stations:
NWS=4;                  % a) CERTE, b) Merra, c) Era, d) WTK
% Counter:
count=0;
YEAR=[];TURB={};WBASE={};TEP={};
% Economic Analysis with Annual Net Power:
ROIN=[];TIRN=[];PBN=[];PBDN=[];
NPCN=[];COEN=[];
% Net power + CEL:
ROIC=[];TIRC=[];PBC=[];PBDC=[];
NPCC=[];COEC=[];
%--------------------------------------------------------------------------
% Economic model for all wheather stations with PMLs:
%--------------------------------------------------------------------------
% RWS:
%PEL1=[];PEL1.P1=[];PEL1.P2=[];PEL1.P3=[];PEL1.P4=[];
RWS=[];
for i=1:4
   for j=1:NY1
       % Update counter:
       count=count+1;
       % PEL=PEL1.P1.Y2018;
       PEL=eval(strcat('PEL1.P',num2str(i,'%.0f'), '.Y',num2str(PEL1.Y(j),'%.0f')));
       % Economic Model:
       [REA, WT] = ECONOMIC_MODEL(WF,WT,PEL,ED);
       % Extract Data:
       YEAR(count)=PEL.yy;
       TURB{count}=PEL.WT;
       WBASE{count}=PEL.WBASE;
       TEP{count}=PEL.ERATE2;
       % Economic Analysis with Annual Net Power:
       ROIN(count)=REA.REPN.ROI;
       TIRN(count)=REA.REPN.TIR;
       PBN(count)=REA.REPN.PB;
       PBDN(count)=REA.REPN.PBD;
       NPCN(count)=REA.NET.NPC(end);
       COEN(count)=REA.NET.COE(end);
       % Net power + CEL:
       ROIC(count)=REA.REPC.ROI;
       TIRC(count)=REA.REPC.TIR;
       PBC(count)=REA.REPC.PB;
       PBDC(count)=REA.REPC.PBD;
       NPCC(count)=REA.NET.NPCC(end);
       COEC(count)=REA.NET.COEC(end);
       % Save REA:
       yy=strcat('PEL1P',num2str(i,'%.0f'),'Y',num2str(PEL1.Y(j),'%.0f'));
       % Economic results of Wheather stations:
       RWS= setfield(RWS,yy,REA);
   end
end
%--------------------------------------------------------------------------
% Economic model for all wheather stations with GMDTH:
%--------------------------------------------------------------------------
for i=1:4
   for j=1:NY2
       % Update counter:
       count=count+1;
       % PEL=PEL1.P1.Y2018;
       PEL=eval(strcat('PEL2.P',num2str(i,'%.0f'), '.Y',num2str(PEL2.Y(j),'%.0f')));
       % Economic Model:
       [REA, WT] = ECONOMIC_MODEL(WF,WT,PEL,ED);
       % Extract Data:
       YEAR(count)=PEL.yy;
       TURB{count}=PEL.WT;
       WBASE{count}=PEL.WBASE;
       TEP{count}=PEL.ERATE1;
       % Economic Analysis with Annual Net Power:
       ROIN(count)=REA.REPN.ROI;
       TIRN(count)=REA.REPN.TIR;
       PBN(count)=REA.REPN.PB;
       PBDN(count)=REA.REPN.PBD;
       NPCN(count)=REA.NET.NPC(end);
       COEN(count)=REA.NET.COE(end);
       % Net power + CEL:
       ROIC(count)=REA.REPC.ROI;
       TIRC(count)=REA.REPC.TIR;
       PBC(count)=REA.REPC.PB;
       PBDC(count)=REA.REPC.PBD;
       NPCC(count)=REA.NET.NPCC(end);
       COEC(count)=REA.NET.COEC(end);
       % Save REA:
       yy=strcat('PEL2P',num2str(i,'%.0f'),'_',num2str(PEL2.Y(j),'%.0f'));
       % Economic results of Wheather stations:
       RWS= setfield(RWS,yy,REA);
   end
       RWS=setfield(RWS,'TU',TURB);
end
count=0;
%--------------------------------------------------------------------------
% Excel:
%--------------------------------------------------------------------------
% PN: Net power,
% PND: Net power + Discount,
% PNC: Net power + CEL,
% PNDC: Net power + Discount + CEL,
H1={'Year', 'Weather Station','Wind Turbine','Type of Energy', 'PB_PN','PB_PND','PB_PNC', 'PB_PNDC',...
    'ROI_PN', 'ROI_PNC', 'TIR_PN','TIR_PNC',...
    'COE_PN','COE_PNC','NPC_PN','NPC_PNC'};
H2={'' '' '' '' 'Years' 'Years' 'Years' 'Years'...
    '(%)' '(%)' '(%)' '(%)'...
    '($/kWh)' '($/kWh)' '($)' '($)'};
% classG=[YEAR' WBASE' TURB' TEP' PBN'...
%        PBDN' PBC' PBDC' ROIN'...
%        ROIC' TIRN' TIRC' COEN' COEC'...
%        NPCN' NPCC'];
classG=[YEAR'  PBN'...
       PBDN' PBC' PBDC' ROIN'...
       ROIC' TIRN' TIRC' COEN' COEC'...
       NPCN' NPCC'];
APLTCASES=1;
% Write an Excel file:
xlswrite('APLTCASES',H1,'APLTCASES','A1');
xlswrite('APLTCASES',H2,'APLTCASES','A2');
xlswrite('APLTCASES',classG(:,1),'APLTCASES','A3');
xlswrite('APLTCASES',WBASE','APLTCASES','B3');
xlswrite('APLTCASES',TURB','APLTCASES','C3');
xlswrite('APLTCASES',TEP','APLTCASES','D3');
xlswrite('APLTCASES',classG(:,2:end),'APLTCASES','E3');