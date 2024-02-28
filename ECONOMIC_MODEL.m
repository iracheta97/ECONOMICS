function [REA, WT] = ECONOMIC_MODEL(WF,WT,PEL,ED)

% This program resolves the economic model of a wind farm:
% Inputs:
% WF:          Wind Farm data,
% WT:          Wind Turbine data,
% PEL:         Structure of power profile,
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
% Results of the Economic Analysis (REA)
% REA STRUCTURE:
% REA.CRF:      Capital Recovery Factor,
% REA.AGS;      Number of Wind Turbines,
% REA.CC:       Total capital costs,
% REA.TACC:     Total anualized capital cost (USD),
% REA.TARC:     Total annualized replacement cost (USD),
% REA.FUEL:     Fuel cost (USD),
% REA.GROSS:    Results with gross power,
% REA.NET:      Results with net power,
% REA.WPG:      Wind production with gross power,
% REA.WPN:      Wind production with net power,
% REA.FCASHG:   Flow cash with gross power,
% REA.FCASHN:   Flow cash with net power;
% REA.FCASHC:   Flowcash with net power + incentives;
% REA.PRODG:    Production of wind gross energy,
% REA.PRODN:    Production of wind net energy,
% REA.OPT:      Optimizating the results of economic analysis,

% COST STRUCTURE
% COST.CC.DATA.- Capital Cost (USD)
% COST.OP.DATA.-Operating Costs(USD)
% COST.OMT.DATA.- Operation and Maintenance Costos (USD),
% WP.- Wind Production Data Structure (kW/yr),
% DF.- Discount Factor (DF),
% FCASH.- Costs with Discount Factor (USD).
% VA.-    Present Value,
% VAN.-   Net Present Value,
% POWER:  Electricity Production of a Single Turbine
% OPT:    Structure Data of Economic Results,
% REP:    Report Data,
% TOTAL:    Breakdown of Costs (USD),
% ECO:      Economic Results,
% WT:       Update WT.plot
%--------------------------------------------------------------------------
% Input variables:
%--------------------------------------------------------------------------
PGROSS=PEL.GROSS;    % Annual Gross Energy profile (kW) (8760 Data),
PNET=PEL.NET;        % Annual Net Energy profile (kW) (8760 Data),
EP1=PEL.EPR1;        % Annual Electricity price profile (USD/kW) (8760 Data),
EP2=PEL.EPR2;        % Annual Electricity price profile (USD/kW) (8760 Data),
LOAD1=PEL.LOAD1;     % Annual Load Profile in kW (8760 Data),
LOAD2=PEL.LOAD2;     % Annual Load Profile in kW (8760 Data),
% Incentives:
CEL=ED.CEL;          % USD/kW
% Plot:
p1=ED.P1;
% Excel file:
pex=ED.P2;
% Exchange rate:
TC=20.10;            % MXN/US
%--------------------------------------------------------------------------
% Conditioning equal Input lengths:
%--------------------------------------------------------------------------
LOAD=0*LOAD1;        % kW
EP=EP1;              % USD/kW
ff1=length(PGROSS);
ff2=length(EP);
ff3=length(LOAD);
ff=[ff1;ff2;ff3];
[x1 x2]=min(ff);
% Production of a Single Wind Farm (kW):
PGROSS=PGROSS(1:x1);
PNET=PNET(1:x1);
EP=EP(1:x1);
LOAD=LOAD(1:x1);
%--------------------------------------------------------------------------
% Samples per hour:
%--------------------------------------------------------------------------
F=length(PGROSS)/8760;
%--------------------------------------------------------------------------
% Capital Recovery Factor (CRF):
%--------------------------------------------------------------------------
R=ED.R;                             % Real Interest;
PL=ED.PL;                           % Project Life;
CRF=(R/100)*power((1+R/100),PL)/(power(1+R/100,PL)-1);
%--------------------------------------------------------------------------
% Operating Cost ($/kW) and Energy Production (kWh)/yr:
%--------------------------------------------------------------------------
NWT=WF.N;                           % Number of wind turbines
CC=ED.CC;                           % Capital Cost (USD)
OM=ED.OM;                           % Operating and Maintenance Cost (USD)
for i=1:NWT+1
    % Grid:
    G(i,:)=1;                                               % Power Network
    % Turbine:
    AGS(i,:)=i-1;                                           % Number of Wind Turbines 
    % Total Capital Costs:
    CCT(i,:)=WT.P*CC*(i-1);                                  % USD
    % Total Annualized Capital Cost:
    TACC(i,:)=CCT(i,:)*CRF;                                  % USD
    % Total Annualized Replacement Cost:
    TARC(i,:)=0;                                             % USD
    % Operation and Maintenance Cost:
    OMT(i,:)=WT.P*CC*OM/100*(i-1);                           % USD
    % Power Grid (With gross and net power):
    GRIDG(i,:)=(sum(EP.*(PGROSS*(i-1)-LOAD)))/F;             % USD
    GRIDN(i,:)=(sum(EP.*(PNET*(i-1)-LOAD)))/F;               % USD
    GRIDC(i,:)=(sum((EP+CEL).*(PNET*(i-1)-LOAD)))/F;         % USD
    % Total Fuel Cost:
    FUEL(i,:)=0;                                             % USD
    % Total Annualized Maintenance Cost
    OPG(i,:)= (OMT(i,:)-GRIDG(i,:));                         % USD
    OPN(i,:)= (OMT(i,:)-GRIDN(i,:));                         % USD
    OPC(i,:)= (OMT(i,:)-GRIDC(i,:));                         % USD
    % Total Annualized Cost:                                 % USD
    TACG(i,:)=OPG(i,:)+TACC(i,:);                            % USD
    TACN(i,:)=OPN(i,:)+TACC(i,:);                            % US
    TACCEL(i,:)=OPC(i,:)+TACC(i,:);                          % US
    % Wind Production (kWh/yr):
    WPRODG(i,:)=(i-1)*sum(PGROSS)/F;                         % kWh/yr
    WPRODN(i,:)=(i-1)*sum(PNET)/F;                           % kWh/yr
    % Grid Purchases (kWh/yr);
    GPG=(i-1)*PGROSS-LOAD;                                   % kW
    GPURG(i,:)=abs(sum(GPG(find(GPG<0))))/F;                 % kW/yr
    GPN=(i-1)*PNET-LOAD;                                     % kW
    GPURN(i,:)=abs(sum(GPN(find(GPN<0))))/F;                 % kW/yr
    % Grid Sales (kWh/yr):
    GSALG(i,:)=abs(sum(GPG(find(GPG>0))))/F;                 % kW/yr
    GSALN(i,:)=abs(sum(GPN(find(GPN>0))))/F;                 % kW/yr
    % Grid Net Purchases (kWh/yr):
    GNPG(i,:)= GPURG(i,:)-GSALG(i,:);                        % kW/yr
    GNPN(i,:)= GPURN(i,:)-GSALN(i,:);                        % kW/yr
    % Total Electrical Production (kW/yr):
    GTEPG(i,:)=WPRODG(i,:)+GPURG(i,:);                       % kW/yr
    GTEPN(i,:)=WPRODN(i,:)+GPURN(i,:);                       % kW/yr
    % AC Primary Load Served (kW/yr)
    PACL(i,:)=sum(LOAD)/F;                                   % kW/yr
    % Renewable Fraction (%):
    if i==1
        RFG(i,:)=0;                                           % %
        RFN(i,:)=0;                                           % %
    else
        RFG(i,:)=100*WPRODG(i,:)/GTEPG(i,:);                  % %
        RFN(i,:)=100*WPRODN(i,:)/GTEPN(i,:);                  % %
    end
    % NPC:
    NPCG(i,:)=TACG(i,:)/CRF;                                   % USD
    NPCN(i,:)=TACN(i,:)/CRF;                                   % USD
    NPCC(i,:)=TACCEL(i,:)/CRF;                                 % USD
    % Levelized Cost of Energy (USD:
    COEG(i,:)=TACG(i,:)/GTEPG(i,:);                            % USD/kW
    COEN(i,:)=TACN(i,:)/GTEPN(i,:);                            % USD/kW
    COEC(i,:)=TACCEL(i,:)/GTEPN(i,:);                          % USD/kW
end
%--------------------------------------------------------------------------
% Discount Factor and Cash Flow:
%--------------------------------------------------------------------------
CAF=[];
WFARM=zeros(5,PL+1,NWT+1);
PGRIDG=zeros(5,PL+1,NWT+1);
PGRIDN=zeros(5,PL+1,NWT+1);
PGRIDC=zeros(5,PL+1,NWT+1);
% With Discount:
WFARMD=zeros(5,PL+1,NWT+1);
PGRIDDG=zeros(5,PL+1,NWT+1);
PGRIDDN=zeros(5,PL+1,NWT+1);
PGRIDDC=zeros(5,PL+1,NWT+1);
for i=1:PL+1
    DF(i,:)=1/power((1+R/100),i-1);
    if i==1
        WFARM(1,i,:)=-CCT;                     % USD
        WFARMD(1,i,:)=-CCT;                    % USD
    elseif i>1
        % O&M:
        WFARM(3,i,:)=-OMT;                     % USD
        WFARMD(3,i,:)=-DF(i,:)*OMT;            % USD
        % Operating:
        PGRIDG(3,i,:)=GRIDG;                   % USD
        PGRIDN(3,i,:)=GRIDN;                   % USD
        PGRIDC(3,i,:)=GRIDC;                   % USD
        PGRIDDG(3,i,:)=DF(i,:)*GRIDG;          % USD
        PGRIDDN(3,i,:)=DF(i,:)*GRIDN;          % USD
        PGRIDDC(3,i,:)=DF(i,:)*GRIDC;          % USD
    end
end
%--------------------------------------------------------------------------
% Results of economic analysis (REA):
%--------------------------------------------------------------------------
% REA Structure:
REA=[];
REA= setfield(REA,'CRF',CRF);              % Capital recovery factor (CRF),
REA= setfield(REA,'AGS',AGS);              % Number of Wind Turbines,
REA= setfield(REA,'CC',CCT);               % Total capital costs,
REA= setfield(REA,'TACC',TACC);            % Total Annualized Capital Cost (USD),
REA= setfield(REA,'TARC',TARC);            % Total Annualized Replacement Cost (USD),
REA= setfield(REA,'OM',OMT);               % Operating and maintenance cost (USD),
REA= setfield(REA,'FUEL',FUEL);            % Fuel Cost (USD)
% Gross power:
REA.GROSS=[];
REA.GROSS= setfield(REA.GROSS,'GRID',GRIDG);
REA.GROSS= setfield(REA.GROSS,'OP',OPG);
REA.GROSS= setfield(REA.GROSS,'NPC',NPCG);   % Net Present Cost (USD)
REA.GROSS= setfield(REA.GROSS,'TAC',TACG);   % Total Annualized Cost USD
REA.GROSS= setfield(REA.GROSS,'COE',COEG);   % Levelized Cost of Energy (USD/kWh)
REA.GROSS= setfield(REA.GROSS,'UNITS','U0.S Dollar');
% Net power:
REA.NET=[];
REA.NET= setfield(REA.NET,'GRID',GRIDN);    % Energy sell income without considering incentives
REA.NET= setfield(REA.NET,'GRIDC',GRIDC);   % Energy sell to the network including incentives
REA.NET= setfield(REA.NET,'OP',OPN);
REA.NET= setfield(REA.NET,'OPC',OPC);
REA.NET= setfield(REA.NET,'NPC',NPCN);      % Net Present Cost (USD)
REA.NET= setfield(REA.NET,'NPCC',NPCC);     % Net Present Cost (USD) including incentives
REA.NET= setfield(REA.NET,'TAC',TACN);      % Total Annualized Cost USD
REA.NET= setfield(REA.NET,'TACC',TACCEL);   % Total Annualized Cost USD with incentives,
REA.NET= setfield(REA.NET,'COE',COEN);      % Levelized Cost of Energy (USD/kWh)
REA.NET= setfield(REA.NET,'COEC',COEC);     % Levelized Cost of Energy (USD/kWh)
REA.NET= setfield(REA.NET,'UNITS','U0.S Dollar');
% Wind production (Gross):
REA.WPG=[];
REA.WPG=setfield(REA.WPG,'WPROD',WPRODG);
REA.WPG=setfield(REA.WPG,'GPUR',GPURG);     % Grid Purchases
REA.WPG=setfield(REA.WPG,'GSAL',GSALG);     % Grid Sales
REA.WPG=setfield(REA.WPG,'GNP',GNPG);       % Grid Net Purchase
REA.WPG=setfield(REA.WPG,'GTEP',GTEPG);     % Total Electricity Production
REA.WPG=setfield(REA.WPG,'PACL',PACL);      % AC Primary Load Served (kW/yr)
REA.WPG=setfield(REA.WPG,'UNITS','kWh/yr'); % Units (kWh/yr)
REA.WPG=setfield(REA.WPG,'RF',RFG);         % Renewable Fraction (%)
% Wind production (Net):
REA.WPN=[];
REA.WPN=setfield(REA.WPN,'WPROD',WPRODN);
REA.WPN=setfield(REA.WPN,'GPUR',GPURN);     % Grid Purchases
REA.WPN=setfield(REA.WPN,'GSAL',GSALN);     % Grid Sales
REA.WPN=setfield(REA.WPN,'GNP',GNPN);       % Grid Net Purchase
REA.WPN=setfield(REA.WPN,'GTEP',GTEPN);     % Total Electricity Production
REA.WPN=setfield(REA.WPN,'PACL',PACL);      % AC Primary Load Served (kW/yr)
REA.WPN=setfield(REA.WPN,'UNITS','kWh/yr'); % Units (kWh/yr)
REA.WPN=setfield(REA.WPN,'RF',RFN);         % Renewable Fraction (%)
% Total Flow Cash (USD):
% Gross
TOTALG=sum(WFARM+PGRIDG,1);                 % USD
TOTALDG=sum(WFARMD+PGRIDDG,1);              % USD
VAG(:,1)=sum(TOTALDG);                      % USD
VANG=VAG-CCT;                               % USD
% Net:
TOTALN=sum(WFARM+PGRIDN,1);                 % USD
TOTALDN=sum(WFARMD+PGRIDDN,1);              % USD
VAN(:,1)=sum(TOTALDN);                      % USD
VANN=VAN-CCT;                               % USD
% Net + Taxes:
% [xNT,TAXNT,TAXSUMNT]=ISR(TOTALN,TC);        % USD
% [xDNT,TAXDNT,TAXSUMDNT]=ISR(TOTALDN,TC);    % USD
% TOTALNT=TOTALN-TAXNT;                       % USD
% TOTALDNT=TOTALDN-TAXDNT;                    % USD
% VAN(:,1)=sum(TOTALDNT);                     % USD
VANNT=VANN;                                   % USD
% Net+Incentives:
TOTALC=sum(WFARM+PGRIDC,1);                 % USD
TOTALDC=sum(WFARMD+PGRIDDC,1);              % USD
VAN(:,1)=sum(TOTALDC);                      % USD
VANC=VAN-CCT;                               % USD
% Net + Incentives+ Taxes:
% [xCT,TAXCT,TAXSUMCT]=ISR(TOTALC,TC);        % USD
% [xDCT,TAXDCT,TAXSUMDCT]=ISR(TOTALDC,TC);    % USD
% TOTALCT=TOTALC-TAXCT;                       % USD
% TOTALDCT=TOTALDC-TAXDCT;                    % USD
% VAN(:,1)=sum(TOTALDCT);                     % USD
VANCT=VANC;                                   % USD
% Flow Cash:
% Gross:
REA.FCASHG=[];
REA.FCASHG= setfield(REA.FCASHG,'WFARM',WFARM);
REA.FCASHG= setfield(REA.FCASHG,'PGRID',PGRIDG);
REA.FCASHG= setfield(REA.FCASHG,'TOTAL',TOTALG);
REA.FCASHG= setfield(REA.FCASHG,'WFARMD',WFARMD);
REA.FCASHG= setfield(REA.FCASHG,'PGRIDD',PGRIDDG);
REA.FCASHG= setfield(REA.FCASHG,'TOTALD',TOTALDG);
REA.FCASHG= setfield(REA.FCASHG,'UNITS','US Dollar');
% Net:
REA.FCASHN=[];
REA.FCASHN= setfield(REA.FCASHN,'WFARM',WFARM);
REA.FCASHN= setfield(REA.FCASHN,'PGRID',PGRIDN);
REA.FCASHN= setfield(REA.FCASHN,'TOTAL',TOTALN);
REA.FCASHN= setfield(REA.FCASHN,'WFARMD',WFARMD);
REA.FCASHN= setfield(REA.FCASHN,'PGRIDD',PGRIDDN);
REA.FCASHN= setfield(REA.FCASHN,'TOTALD',TOTALDN);
REA.FCASHN= setfield(REA.FCASHN,'UNITS','US Dollar');
% Net+taxes:
REA.FCASHNT=[];
REA.FCASHNT= setfield(REA.FCASHNT,'WFARM',WFARM);
REA.FCASHNT= setfield(REA.FCASHNT,'PGRID',PGRIDN);
REA.FCASHNT= setfield(REA.FCASHNT,'TOTAL',TOTALN);
REA.FCASHNT= setfield(REA.FCASHNT,'WFARMD',WFARMD);
REA.FCASHNT= setfield(REA.FCASHNT,'PGRIDD',PGRIDDN);
REA.FCASHNT= setfield(REA.FCASHNT,'TOTALD',TOTALDN);
REA.FCASHNT= setfield(REA.FCASHNT,'UNITS','US Dollar');
% Net+Incentives:
REA.FCASHC=[];
REA.FCASHC= setfield(REA.FCASHC,'WFARM',WFARM);
REA.FCASHC= setfield(REA.FCASHC,'PGRID',PGRIDC);
REA.FCASHC= setfield(REA.FCASHC,'TOTAL',TOTALC);
REA.FCASHC= setfield(REA.FCASHC,'WFARMD',WFARMD);
REA.FCASHC= setfield(REA.FCASHC,'PGRIDD',PGRIDDC);
REA.FCASHC= setfield(REA.FCASHC,'TOTALD',TOTALDC);
REA.FCASHC= setfield(REA.FCASHC,'UNITS','US Dollar');
% Net+Incentives+Taxes:
REA.FCASHCT=[];
REA.FCASHCT= setfield(REA.FCASHCT,'WFARM',WFARM);
REA.FCASHCT= setfield(REA.FCASHCT,'PGRID',PGRIDC);
REA.FCASHCT= setfield(REA.FCASHCT,'TOTAL',TOTALC);
REA.FCASHCT= setfield(REA.FCASHCT,'WFARMD',WFARMD);
REA.FCASHCT= setfield(REA.FCASHCT,'PGRIDD',PGRIDDC);
REA.FCASHCT= setfield(REA.FCASHCT,'TOTALD',TOTALDC);
REA.FCASHCT= setfield(REA.FCASHCT,'UNITS','US Dollar');
%--------------------------------------------------------------------------
% OPTIMIZATION RESULTS:
%--------------------------------------------------------------------------
% Gross:
[BG,IG]=sort(NPCG);
% Net:
[BN,IN]=sort(NPCN);
% Net +incentives:
[BC,IC]=sort(NPCC);
H1={'Grid', 'Turbines', 'Total Capital Cost','Tot Ann. Cap Cost', 'Tot. Ann. Repl. Cost',...
    'Total O&M Cost', 'Total Fuel Cost', 'Total Ann. Cost', 'Operating Cost',...
    'Total NPC', 'COE','Wind Production','Grid Purachases', 'Grid Sales',...
    'Grid Net Purchases', 'Tot. Electrical Production', 'AC Primary Load Served'...
    'Renewable Fraction'};
H2={'' '' '($/yr)' '($/yr)' '($/yr)'...
    '($/yr)' '($/yr)' '($/yr)' '($/yr)'...
    '($)' '($/kWh)' '(kWh/yr)' '(kWh/yr)' '(kWh/yr)'...
    '(kWh/yr)' '(kWh/yr)' '(kWh/yr)' '(%)'};
classG=[G(IG) AGS(IG) CCT(IG) TACC(IG) TARC(IG)...
       OMT(IG) FUEL(IG) TACG(IG) OPG(IG)...
       NPCG(IG) COEG(IG) WPRODG(IG) GPURG(IG) GSALG(IG)...
       GNPG(IG) GTEPG(IG) PACL(IG) RFG(IG)];
classN=[G(IN) AGS(IN) CCT(IN) TACC(IN) TARC(IN)...
       OMT(IN) FUEL(IN) TACN(IN) OPN(IN)...
       NPCN(IN) COEN(IN) WPRODN(IN) GPURN(IN) GSALN(IN)...
       GNPN(IN) GTEPN(IN) PACL(IN) RFN(IN)];
classC=[G(IN) AGS(IN) CCT(IN) TACC(IN) TARC(IN)...
       OMT(IN) FUEL(IN) TACCEL(IN) OPN(IN)...
       NPCC(IN) COEC(IN) WPRODN(IN) GPURN(IN) GSALN(IN)...
       GNPN(IN) GTEPN(IN) PACL(IN) RFN(IN)];
if pex==1
OPTIMIZATIONG=1;
% Write an Excel file:
xlswrite('OPTIMIZATION',H1,'OPTIMIZATIONG','A1');
xlswrite('OPTIMIZATION',H2,'OPTIMIZATIONG','A2');
xlswrite('OPTIMIZATION',classG,'OPTIMIZATIONG','A3');
OPTIMIZATIONN=2;
xlswrite('OPTIMIZATION',H1,'OPTIMIZATIONN','A1');
xlswrite('OPTIMIZATION',H2,'OPTIMIZATIONN','A2');
xlswrite('OPTIMIZATION',classN,'OPTIMIZATIONN','A3');
OPTIMIZATIONC=3;
xlswrite('OPTIMIZATION',H1,'OPTIMIZATIONC','A1');
xlswrite('OPTIMIZATION',H2,'OPTIMIZATIONC','A2');
xlswrite('OPTIMIZATION',classC,'OPTIMIZATIONC','A3');
end
%--------------------------------------------------------------------------
% Variable OPT: Structure Data
%--------------------------------------------------------------------------
%OPTIM = {'GRID'; 'WIND TURBINE'; 'Initial Capital (Mill. USD)';'Operating ($/yr)','TOTAL NPC','COE ($/kWh)','Ren. Frac.'};
% Gross:
% Capital Cost (USD/kW):
CapG=CCT;
% Number of Turbines
Turb=[0:WF.N]';
% Grid Costs (USD/kW):
GridG=0*CCT+1;
% Operating Costs (USD/kW):
OperatingG=OPG;
% Operation & Maintenance Cost (USD/kW):
OMTG=-OMT;
% Sales Costs (USD/kW):
GRID_SALESG=GRIDG;
% Net Present Cost (USD/kW):
NPCG=NPCG;
% Table of Results:
OPTG= table(GridG,Turb,CapG,OMTG, GRID_SALESG, OperatingG,NPCG);
REA.OPT=[];
REA.OPT= setfield(REA.OPT,'OPTG',OPTG);
% Net:
% Capital Cost (USD/kW):
CapN=CCT;
% Grid Costs (USD/kW):
GridN=0*CCT+1;
% Operating Costs (USD/kW):
OperatingN=OPN;
% Operation & Maintenance Cost (USD/kW):
OMTN=-OMT;
% Sales Costs (USD/kW):
GRID_SALESN=GRIDN;
% Net Present Cost (USD/kW):
NPCN=NPCN;
% Table of Results:
OPTN= table(GridN,Turb,CapN,OMTN, GRID_SALESN, OperatingN,NPCN);
REA.OPT=[];
REA.OPT= setfield(REA.OPT,'OPTN',OPTN);
% Net+Incentives:
% Capital Cost (USD/kW):
CapN=CCT;
% Grid Costs (USD/kW):
GridN=0*CCT+1;
% Operating Costs (USD/kW):
OperatingC=OPC;
% Operation & Maintenance Cost (USD/kW):
OMTC=-OMT;
% Sales Costs (USD/kW):
GRID_SALESC=GRIDC;
% Net Present Cost (USD/kW):
NPCC=NPCC;
% Table of Results:
OPTC= table(GridN,Turb,CapN,OMTC, GRID_SALESC, OperatingC,NPCC);
REA.OPT=[];
REA.OPT= setfield(REA.OPT,'OPTC',OPTC);
%--------------------------------------------------------------------------
% Production of Electricity:
%--------------------------------------------------------------------------
% PGROSS:
PRODG=[];CONSG=[];QUANG=[];REPG=[];
% PNET:
PRODN=[];CONSN=[];QUANN=[];REPN=[];
%--------------------------------------------------------------------------
% Grid Purchases:
%--------------------------------------------------------------------------
% Gross:
% Samples per Hour:
EFG=length(PGROSS)/8760;
% Wind Turbine:
SPWG=sum(PGROSS)/EFG;                       % Electriciy Production
GPURG=PGROSS-LOAD;                          % kW
SPG=abs(sum(GPURG(find(GPURG<=0))))/EFG;    % kW/yr
TOTALG=SPWG+SPG;                            % kW
REA.PRODG=[];
REA.PRODG= setfield(REA.PRODG,'WT',SPWG);
REA.PRODG= setfield(REA.PRODG,'WTP',100*SPWG/TOTALG);           % %
REA.PRODG= setfield(REA.PRODG,'GP',SPG);                        % kW
REA.PRODG= setfield(REA.PRODG,'GPP',100*SPG/TOTALG);            % %
REA.PRODG= setfield(REA.PRODG,'TOTAL',TOTALG);
REA.PRODG= setfield(REA.PRODG,'UNITS','kWh/yr');
% Net:
% Samples per Hour:
EFN=length(PNET)/8760;
% Wind Turbine:
SPWN=sum(PNET)/EFN; 
GPURN=PNET-LOAD;                           % kW
SPN=abs(sum(GPURN(find(GPURN<=0))))/EFN;   % kW/yr
TOTALN=SPWN+SPN;                           % kW
REA.PRODN=[];
REA.PRODN= setfield(REA.PRODN,'WT',SPWN);
REA.PRODN= setfield(REA.PRODN,'WTP',100*SPWN/TOTALN);           % %
REA.PRODN= setfield(REA.PRODN,'GP',SPN);                        % kW
REA.PRODN= setfield(REA.PRODN,'GPP',100*SPN/TOTALN);            % %
REA.PRODN= setfield(REA.PRODN,'TOTAL',TOTALN);
REA.PRODN= setfield(REA.PRODN,'UNITS','kWh/yr');
%--------------------------------------------------------------------------
% Grid Sales:
%--------------------------------------------------------------------------
% Gross:
SCONSG=sum(LOAD)/EFG;                                % Load Consuption
GSG=abs(sum(GPURG(find(GPURG>=0))));                 % kW/yr
TOTALG=GSG+SCONSG;
REA.PRODG=[];
REA.PRODG= setfield(REA.PRODG,'LOAD',SCONSG);                   % kW
REA.PRODG= setfield(REA.PRODG,'LOADP',100*SCONSG/TOTALG);       % kW
REA.PRODG= setfield(REA.PRODG,'GS',GSG);                        % kW
REA.PRODG= setfield(REA.PRODG,'GSP',100*GSG/TOTALG);            % %
REA.PRODG= setfield(REA.PRODG,'TOTAL',(SCONSG+GSG));            % kW
REA.PRODG= setfield(REA.PRODG,'UNITS','kWh/yr');
% Net:
SCONSN=sum(LOAD)/EFN;                                 % Load Consuption
GSN=abs(sum(GPURN(find(GPURN>=0))));                  % kW/yr
TOTALN=GSN+SCONSN;
REA.PRODN=[];
REA.PRODN= setfield(REA.PRODN,'LOAD',SCONSN);                   % kW
REA.PRODN= setfield(REA.PRODN,'LOADP',100*SCONSN/TOTALN);       % kW
REA.PRODN= setfield(REA.PRODN,'GS',GSN);                        % kW
REA.PRODN= setfield(REA.PRODN,'GSP',100*GSN/TOTALN);            % %
REA.PRODN= setfield(REA.PRODN,'TOTAL',(SCONSN+GSN));            % kW
REA.PRODN= setfield(REA.PRODN,'UNITS','kWh/yr');
%--------------------------------------------------------------------------
% Quantity:
%--------------------------------------------------------------------------
REA.QUAN=[];
REA.QUAN= setfield(REA.QUAN,'RFG',100*SPWG/TOTALG);
REA.QUAN= setfield(REA.QUAN,'RFN',100*SPWN/TOTALN);
%--------------------------------------------------------------------------
% Summary Costs:
%--------------------------------------------------------------------------
CASE=ED.CASE;
% Gross:
SUMCOSTG=REA.FCASHG.TOTAL(:,:,CASE);
% Net:
SUMCOSTN=REA.FCASHN.TOTAL(:,:,CASE);
% Net + Incentives:
SUMCOSTC=REA.FCASHC.TOTAL(:,:,CASE);
Component = {'Turbine';'Grid';'System'};
%--------------------------------------------------------------------------
% Summary Cost (USD):
%--------------------------------------------------------------------------
SC=ED.SC;
% Project Life (Years):
PL=ED.PL;
% Summary costs:
if SC==1                                    % Present Net:
    CapitalG=[REA.FCASHG.WFARM(1,1,CASE)/1e6;0];
    CapitalN=[REA.FCASHN.WFARM(1,1,CASE)/1e6;0];
    CapitalC=[REA.FCASHC.WFARM(1,1,CASE)/1e6;0];
    CapitalG= [CapitalG; sum(CapitalG)];
    CapitalN= [CapitalN; sum(CapitalN)];
    CapitalC= [CapitalC; sum(CapitalC)];
    ReplacementG=[sum(REA.FCASHG.WFARM(2,2:end,CASE))/1e6;0];
    ReplacementN=[sum(REA.FCASHN.WFARM(2,2:end,CASE))/1e6;0];
    ReplacementC=[sum(REA.FCASHC.WFARM(2,2:end,CASE))/1e6;0];
    ReplacementG=[ReplacementG; sum(ReplacementG)];
    ReplacementN=[ReplacementN; sum(ReplacementN)];
    ReplacementC=[ReplacementC; sum(ReplacementC)];
    OperatingG= [sum(REA.FCASHG.WFARMD(3,:,CASE))/1e6;sum(REA.FCASHG.PGRIDD(3,:,CASE))/1e6];
    OperatingN= [sum(REA.FCASHN.WFARMD(3,:,CASE))/1e6;sum(REA.FCASHN.PGRIDD(3,:,CASE))/1e6];
    OperatingC= [sum(REA.FCASHC.WFARMD(3,:,CASE))/1e6;sum(REA.FCASHC.PGRIDD(3,:,CASE))/1e6];
    OperatingG= [OperatingG; sum(OperatingG)];
    OperatingN= [OperatingN; sum(OperatingN)];
    OperatingC= [OperatingC; sum(OperatingC)];
    FuelG=[sum(REA.FCASHG.WFARM(4,:,CASE))/1e6;0];
    FuelN=[sum(REA.FCASHN.WFARM(4,:,CASE))/1e6;0];
    FuelC=[sum(REA.FCASHC.WFARM(4,:,CASE))/1e6;0];
    FuelG= [FuelG; sum(FuelG)];
    FuelN= [FuelN; sum(FuelN)];
    FuelC= [FuelC; sum(FuelC)];
    SalvageG=[sum(REA.FCASHG.WFARM(5,:,CASE));0];
    SalvageN=[sum(REA.FCASHN.WFARM(5,:,CASE));0];
    SalvageC=[sum(REA.FCASHC.WFARM(5,:,CASE));0];
    SalvageG=[SalvageG; sum(SalvageG)];
    SalvageN=[SalvageN; sum(SalvageN)];
    SalvageC=[SalvageC; sum(SalvageC)];
    %SCT='Present Net (Millions $)';
    SCT='Presente Neto (mdd)';
elseif SC==2                               % Annualized
    CapitalG=[REA.FCASHG.WFARM(1,1,CASE)*CRF(end)/1e6;0];
    CapitalN=[REA.FCASHN.WFARM(1,1,CASE)*CRF(end)/1e6;0];
    CapitalC=[REA.FCASHC.WFARM(1,1,CASE)*CRF(end)/1e6;0];
    CapitalG= [CapitalG; sum(CapitalG)];
    CapitalN= [CapitalN; sum(CapitalN)];
    CapitalC= [CapitalC; sum(CapitalC)];
    ReplacementG=[sum(REA.FCASHG.WFARM(2,2:end,CASE))/1e6;0];
    ReplacementN=[sum(REA.FCASHN.WFARM(2,2:end,CASE))/1e6;0];
    ReplacementC=[sum(REA.FCASHC.WFARM(2,2:end,CASE))/1e6;0];
    ReplacementG=[ReplacementG; sum(ReplacementG)];
    ReplacementN=[ReplacementN; sum(ReplacementN)];
    ReplacementC=[ReplacementC; sum(ReplacementC)];
    OperatingG= [sum(REA.FCASHG.WFARM(3,:,CASE)/PL)/1e6;sum(REA.FCASHG.PGRID(3,:,CASE)/PL)/1e6];
    OperatingN= [sum(REA.FCASHN.WFARM(3,:,CASE)/PL)/1e6;sum(REA.FCASHN.PGRID(3,:,CASE)/PL)/1e6];
    OperatingC= [sum(REA.FCASHC.WFARM(3,:,CASE)/PL)/1e6;sum(REA.FCASHC.PGRID(3,:,CASE)/PL)/1e6];
    OperatingG= [OperatingG; sum(OperatingG)];
    OperatingN= [OperatingN; sum(OperatingN)];
    OperatingC= [OperatingC; sum(OperatingC)];
    FuelG=[sum(REA.FCASHG.WFARM(4,:,CASE))/1e6;0];
    FuelN=[sum(REA.FCASHN.WFARM(4,:,CASE))/1e6;0];
    FuelC=[sum(REA.FCASHC.WFARM(4,:,CASE))/1e6;0];
    FuelG= [FuelG; sum(FuelG)];
    FuelN= [FuelN; sum(FuelN)];
    FuelC= [FuelC; sum(FuelC)];
    SalvageG=[sum(REA.FCASHG.WFARM(5,:,CASE));0];
    SalvageN=[sum(REA.FCASHN.WFARM(5,:,CASE));0];
    SalvageC=[sum(REA.FCASHC.WFARM(5,:,CASE));0];
    SalvageG=[SalvageG; sum(SalvageG)];
    SalvageN=[SalvageN; sum(SalvageN)];
    SalvageC=[SalvageC; sum(SalvageC)];
    %SCT='Annualized Value (Millions $)';
    SCT='Valor Anualizado (mdd)';
end
% Gross:
T1G=[CapitalG ReplacementG OperatingG FuelG SalvageG];
TOTALG= CapitalG+ReplacementG+OperatingG+FuelG+SalvageG;
REA.REPG=[];
REA.REPG= setfield(REA.REPG,'SCT',SCT);
REA.REPG= setfield(REA.REPG,'T1',T1G);
% Net:
T1N=[CapitalN ReplacementN OperatingN FuelN SalvageN];
TOTALN= CapitalN+ReplacementN+OperatingN+FuelN+SalvageN;
REA.REPN=[];
REA.REPN= setfield(REA.REPN,'SCT',SCT);
REA.REPN= setfield(REA.REPN,'T1',T1N);
% Net + Tax:
T1NT=[CapitalN ReplacementN OperatingN FuelN SalvageN];
TOTALNT= CapitalN+ReplacementN+OperatingN+FuelN+SalvageN;
REA.REPNT=[];
REA.REPNT= setfield(REA.REPNT,'SCT',SCT);
REA.REPNT= setfield(REA.REPNT,'T1',T1N);
% Net+Incentives:
T1C=[CapitalC ReplacementC OperatingC FuelC SalvageC];
TOTALC= CapitalC+ReplacementC+OperatingC+FuelC+SalvageC;
REA.REPC=[];
REA.REPC= setfield(REA.REPC,'SCT',SCT);
REA.REPC= setfield(REA.REPC,'T1',T1C);
% Net+Incentives+Taxes:
T1CT=[CapitalC ReplacementC OperatingC FuelC SalvageC];
TOTALCT= CapitalC+ReplacementC+OperatingC+FuelC+SalvageC;
REA.REPCT=[];
REA.REPCT= setfield(REA.REPCT,'SCT',SCT);
REA.REPCT= setfield(REA.REPCT,'T1',T1C);
%--------------------------------------------------------------------------
% By Category:
%--------------------------------------------------------------------------
CAT=ED.CAT;
if CAT==1       % By Component:
   BCG=TOTALG(1:end-1);
   BCN=TOTALN(1:end-1);
   BCC=TOTALC(1:end-1);
   %CAT1='By Component';
   CAT1='Por Componente';
   %CAT2=['WIND TURBINE' 'GRID'];
   CAT2={'Turbina' 'Red Eléctrica'};
elseif CAT==2   % By Cost Type:
   BCG=T1G(end,:);
   BCN=T1N(end,:);
   BCC=T1C(end,:);
   %CAT1='By Cost-Type';
   CAT1='Por Tipo de Costo';
   CAT2={'Capital' 'Reemplazo' 'Operación' 'Combustible' 'Salvamento'};
else
    display('error');
end
% Gross:
REA.REPG= setfield(REA.REPG,'BC',BCG);
REA.REPN= setfield(REA.REPN,'BC',BCN);
REA.REPNT= setfield(REA.REPNT,'BC',BCN);
REA.REPC= setfield(REA.REPC,'BC',BCC);
REA.REPCT= setfield(REA.REPC,'BC',BCC);
% Gross:
REA.REPG= setfield(REA.REPG,'CAT',CAT1);
REA.REPG= setfield(REA.REPG,'CAT2',CAT2);
% Net:
REA.REPN= setfield(REA.REPN,'CAT',CAT1);
REA.REPN= setfield(REA.REPN,'CAT2',CAT2);
% Net+Tax:
REA.REPNT= setfield(REA.REPNT,'CAT',CAT1);
REA.REPNT= setfield(REA.REPNT,'CAT2',CAT2);
% Net+Incentives:
REA.REPC= setfield(REA.REPC,'CAT',CAT1);
REA.REPC= setfield(REA.REPC,'CAT2',CAT2);
% Net+Incentives+Taxes:
REA.REPCT= setfield(REA.REPCT,'CAT',CAT1);
REA.REPCT= setfield(REA.REPCT,'CAT2',CAT2);
%--------------------------------------------------------------------------
% Millions of USD:
%--------------------------------------------------------------------------
% Gross:
TG = table(CapitalG, ReplacementG, OperatingG, FuelG, SalvageG, TOTALG,...
    'RowNames',Component);
% Net:
TN = table(CapitalN, ReplacementN, OperatingN, FuelN, SalvageN, TOTALN,...
    'RowNames',Component);
% Net+Taxes:
TNT=TN;
% Net+incentives:
TNC = table(CapitalC, ReplacementC, OperatingC, FuelC, SalvageC, TOTALC,...
    'RowNames',Component);
% Net+Incentives+Taxes:
TCT=TNC;
%--------------------------------------------------------------------------
% Cash Flow: (Totals) & Acumulative Cash Flow ($):
%--------------------------------------------------------------------------
CF=ED.CF;
if CF==1  % Nominal
    %CASHFG=2;
    SCG='Flujo de Caja Nominal (mdd)';
    % Gross:
    FCASH1G=cumsum(REA.FCASHG.TOTAL(:,:,CASE));
    FCASHBG=cumsum(REA.FCASHG.TOTAL(:,:,1));
    CASHFG=REA.FCASHG.TOTAL(:,:,CASE);
    % Net:
    %CASHFN=2;
    SCN='Flujo de Caja Nominal (mdd)';
    FCASH1N=cumsum(REA.FCASHN.TOTAL(:,:,CASE));
    FCASHBN=cumsum(REA.FCASHN.TOTAL(:,:,1));
    CASHFN=REA.FCASHN.TOTAL(:,:,CASE);
    % Net+Taxes:
    SCNT='Flujo de Caja Nominal (mdd)';
    [x1,TAX1,TAXSUM1]=ISR(FCASH1N,TC);
    FCASH1NT=FCASH1N-TAXSUM1;
    [xB,TAXB,TAXSUMB]=ISR(FCASHBN,TC);
    FCASHBNT=FCASHBN-TAXSUMB;
    [xF,TAXF,TAXSUMF]=ISR(CASHFN,TC);
    CASHFNT=CASHFN-TAXSUMF;
    % Net + incentives:
    SCC='Flujo de Caja Nominal (mdd)';
    FCASH1C=cumsum(REA.FCASHC.TOTAL(:,:,CASE));
    FCASHBC=cumsum(REA.FCASHC.TOTAL(:,:,1));
    CASHFC=REA.FCASHC.TOTAL(:,:,CASE);
    % Net + Incentives + Taxes:
    SCCT='Flujo de Caja Nominal (mdd)';
    [x1CT,TAX1CT,TAXSUM1CT]=ISR(FCASH1C,TC);
    FCASH1CT=FCASH1C-TAXSUM1CT;
    [xBCT,TAXBCT,TAXSUMBCT]=ISR(FCASHBC,TC);
    FCASHBCT=FCASHBC-TAXSUMBCT;
    [xFCT,TAXFCT,TAXSUMFCT]=ISR(CASHFC,TC);
    CASHFCT=CASHFC-TAXSUMFCT;
else  % Discount
    % Gross:
    %CASHFG=REA.FCASHG.TOTALD(:,:,CASE);
    SCG='Flujo de Caja con Descuento (mdd)';
    FCASH1G=cumsum(REA.FCASHG.TOTALD(:,:,CASE));
    FCASHBG=cumsum(REA.FCASHG.TOTALD(:,:,1));
    CASHFG=REA.FCASHG.TOTALD(:,:,CASE);
    % Net:
    %CASHFN=REA.FCASHN.TOTALD(:,:,CASE);
    SCN='Flujo de Caja con Descuento (mdd)';
    FCASH1N=cumsum(REA.FCASHN.TOTALD(:,:,CASE));
    FCASHBN=cumsum(REA.FCASHN.TOTALD(:,:,1));
    CASHFN=REA.FCASHN.TOTALD(:,:,CASE);
    % Net + Taxes:
    SCNT='Flujo de Caja con Descuento (mdd)';
    [x1N,TAX1N,TAXSUM1N]=ISR(FCASH1N,TC);
    FCASH1NT=FCASH1N-TAXSUM1N;
    [xBN,TAXBN,TAXSUMBN]=ISR(FCASHBN,TC);
    FCASHBNT=FCASHBN-TAXSUMBN;
    [xFN,TAXFN,TAXSUMFN]=ISR(CASHFN,TC);
    CASHFNT=CASHFN-TAXSUMFN;
    % Net + incentives:
    SCC='Flujo de Caja con Descuento (mdd)';
    FCASH1C=cumsum(REA.FCASHC.TOTALD(:,:,CASE));
    FCASHBC=cumsum(REA.FCASHC.TOTALD(:,:,1));
    CASHFC=REA.FCASHC.TOTALD(:,:,CASE);
    % Net + incentives + Taxes:
    SCCT='Flujo de Caja con Descuento (mdd)';
    [x1CT,TAX1CT,TAXSUM1CT]=ISR(FCASH1C,TC);
    FCASH1CT=FCASH1C-TAXSUM1CT;
    [xBCT,TAXBCT,TAXSUMBCT]=ISR(FCASHBC,TC);
    FCASHBCT=FCASHBC-TAXSUMBCT;
    [xFC,TAXFC,TAXSUMFC]=ISR(CASHFC,TC);
    CASHFCT=CASHFC-TAXSUMFC;
end
% Gross:
REA.REPG= setfield(REA.REPG,'SC',SCG);
REA.REPG= setfield(REA.REPG,'CASHF',CASHFG);
% Net:
REA.REPN= setfield(REA.REPN,'SC',SCN);
REA.REPN= setfield(REA.REPN,'CASHF',CASHFN);
% Net + Taxes:
REA.REPNT= setfield(REA.REPNT,'SC',SCNT);
REA.REPNT= setfield(REA.REPNT,'CASHF',CASHFNT);
% Net+Incentives:
REA.REPC= setfield(REA.REPC,'SC',SCC);
REA.REPC= setfield(REA.REPC,'CASHF',CASHFC);
% Net+Incentives+Taxes:
REA.REPCT= setfield(REA.REPCT,'SC',SCCT);
REA.REPCT= setfield(REA.REPCT,'CASHF',CASHFCT);
% Acumulative Cash Flow ($):
% Gross:
FCASH1G=cumsum(REA.FCASHG.TOTAL(:,:,CASE));
FCASHBG=cumsum(REA.FCASHG.TOTAL(:,:,1));
FCASH11G=cumsum(REA.FCASHG.TOTALD(:,:,CASE));
FCASHBBG=cumsum(REA.FCASHG.TOTALD(:,:,1));
DIF1G=FCASH1G-FCASHBG;
DIFDG=FCASH11G-FCASHBBG;
REA.REPG= setfield(REA.REPG,'FCASH_CASE',FCASH1G);
REA.REPG= setfield(REA.REPG,'FCASH_BASE',FCASHBG);
REA.REPG= setfield(REA.REPG,'FCASHD_CASE',FCASH11G);
REA.REPG= setfield(REA.REPG,'FCASHD_BASE',FCASHBBG);
REA.REPG= setfield(REA.REPG,'DCASH',DIF1G);
REA.REPG= setfield(REA.REPG,'DCASHD',DIFDG);
% Net:
FCASH1N=cumsum(REA.FCASHN.TOTAL(:,:,CASE));
FCASHBN=cumsum(REA.FCASHN.TOTAL(:,:,1));
FCASH11N=cumsum(REA.FCASHN.TOTALD(:,:,CASE));
FCASHBBN=cumsum(REA.FCASHN.TOTALD(:,:,1));
DIF1N=FCASH1N-FCASHBN;
DIFDN=FCASH11N-FCASHBBN;
REA.REPN= setfield(REA.REPN,'FCASH_CASE',FCASH1N);
REA.REPN= setfield(REA.REPN,'FCASH_BASE',FCASHBN);
REA.REPN= setfield(REA.REPN,'FCASHD_CASE',FCASH11N);
REA.REPN= setfield(REA.REPN,'FCASHD_BASE',FCASHBBN);
REA.REPN= setfield(REA.REPN,'DCASH',DIF1N);
REA.REPN= setfield(REA.REPN,'DCASHD',DIFDN);
% Net + Taxes:
[X1N,TAX1N,TAXSUM1N]=ISR(FCASH1N,TC);
FCASH1NT=FCASH1N-TAXSUM1N;
[XBN,TAXBN,TAXSUMBN]=ISR(FCASHBN,TC);
FCASHBNT=FCASHBN-TAXSUMBN;
[X11N,TAX11N,TAXSUM11N]=ISR(FCASH11N,TC);
FCASH11NT=FCASH11N-TAXSUM11N;
[XBBN,TAXBBN,TAXSUMBBN]=ISR(FCASHBBN,TC);
FCASHBBNT=FCASHBBN-TAXSUMBBN;
DIF1NT=FCASH1NT-FCASHBNT;
DIFDNT=FCASH11NT-FCASHBBNT;
REA.REPNT= setfield(REA.REPNT,'FCASH_CASE',FCASH1NT);
REA.REPNT= setfield(REA.REPNT,'FCASH_BASE',FCASHBNT);
REA.REPNT= setfield(REA.REPNT,'FCASHD_CASE',FCASH11NT);
REA.REPNT= setfield(REA.REPNT,'FCASHD_BASE',FCASHBBNT);
REA.REPNT= setfield(REA.REPNT,'DCASH',DIF1NT);
REA.REPNT= setfield(REA.REPNT,'DCASHD',DIFDNT);
% Net + incentives:
FCASH1C=cumsum(REA.FCASHC.TOTAL(:,:,CASE));
FCASHBC=cumsum(REA.FCASHC.TOTAL(:,:,1));
FCASH11C=cumsum(REA.FCASHC.TOTALD(:,:,CASE));
FCASHBBC=cumsum(REA.FCASHC.TOTALD(:,:,1));
DIF1C=FCASH1C-FCASHBC;
DIFDC=FCASH11C-FCASHBBC;
REA.REPC= setfield(REA.REPC,'FCASH_CASE',FCASH1C);
REA.REPC= setfield(REA.REPC,'FCASH_BASE',FCASHBC);
REA.REPC= setfield(REA.REPC,'FCASHD_CASE',FCASH11C);
REA.REPC= setfield(REA.REPC,'FCASHD_BASE',FCASHBBC);
REA.REPC= setfield(REA.REPC,'DCASH',DIF1C);
REA.REPC= setfield(REA.REPC,'DCASHD',DIFDC);
% Net + incentives + Taxes:
[X1C,TAX1C,TAXSUM1C]=ISR(FCASH1C,TC);
FCASH1CT=FCASH1C-TAXSUM1C;
[XBC,TAXBC,TAXSUMBC]=ISR(FCASHBC,TC);
FCASHBCT=FCASHBC-TAXSUMBC;
[X11C,TAX11C,TAXSUM11C]=ISR(FCASH11C,TC);
FCASH11CT=FCASH11C-TAXSUM11C;
[XBBC,TAXBBC,TAXSUMBBC]=ISR(FCASHBBC,TC);
FCASHBBCT=FCASHBBC-TAXSUMBBC;
DIF1CT=FCASH1CT-FCASHBCT;
DIFDCT=FCASH11CT-FCASHBBCT;
REA.REPCT= setfield(REA.REPCT,'FCASH_CASE',FCASH1CT);
REA.REPCT= setfield(REA.REPCT,'FCASH_BASE',FCASHBCT);
REA.REPCT= setfield(REA.REPCT,'FCASHD_CASE',FCASH11CT);
REA.REPCT= setfield(REA.REPCT,'FCASHD_BASE',FCASHBBCT);
REA.REPCT= setfield(REA.REPCT,'DCASH',DIF1CT);
REA.REPCT= setfield(REA.REPCT,'DCASHD',DIFDCT);
% Present Worth ($):
% Gross:
NPC1G=REA.GROSS.NPC(CASE);
NPCBG=REA.GROSS.NPC(1);
PWORTHG=NPCBG-NPC1G;
REA.REPG= setfield(REA.REPG,'PWORTH',PWORTHG);
% Annual Worth ($):
AWORTHG=PWORTHG*CRF;
REA.REPG= setfield(REA.REPG,'AWORTH',AWORTHG);
% Retorno de la Inversión ($):
% FCASH1G=cumsum(REA.FCASHG.TOTAL(:,:,CASE));
% FCASHBG=cumsum(REA.FCASHG.TOTAL(:,:,1));
% FCASH11G=cumsum(REA.FCASHG.TOTALD(:,:,CASE));
% FCASHBBG=cumsum(REA.FCASHG.TOTALD(:,:,1));
% DIF1G=FCASH1G-FCASHBG;
% DIFDG=FCASH11G-FCASHBBG;
ROIG=(FCASH1G(1)-FCASH1G(end))/(PL*FCASH1G(1))*100;
REA.REPG= setfield(REA.REPG,'ROI',ROIG);
% Internal Rate of Retourn (%):
TIRG=irr(FCASH1G);
% Internal Rate of Retourn (%):
TIRG=irr(FCASH1G)*100;
REA.REPG= setfield(REA.REPG,'TIR',TIRG);
% Simple Payback:                           (Years)
PBG= payback(FCASH1G);                      % Years
REA.REPG= setfield(REA.REPG,'PB',PBG);
% Payback with Discount:
PBDG= payback(FCASH11G);                     % Years
REA.REPG= setfield(REA.REPG,'PBD',PBDG);
% Economic Analysis:
ValueG=[PWORTHG;AWORTHG;ROIG;TIRG;PBG;PBDG];
Component = {'Present Worth ($)';'Anual Worth ($)';'Return of Investment (%)';'Internal Rate of Return (%)'; 'Simple Payback';'Discounted Payback'};
ECOG = table(ValueG,'RowNames',Component);
REA.REPG= setfield(REA.REPG,'ECO',ECOG);
% Net:
NPC1N=REA.NET.NPC(CASE);
NPCBN=REA.NET.NPC(1);
PWORTHN=NPCBN-NPC1N;
REA.REPN= setfield(REA.REPN,'PWORTH',PWORTHN);
% Annual Worth ($):
AWORTHN=PWORTHN*CRF;
REA.REPN= setfield(REA.REPN,'AWORTH',AWORTHN);
% Retorno de la Inversión ($):
ROIN=(FCASH1N(1)-FCASH1N(end))/(PL*FCASH1N(1))*100;
REA.REPN= setfield(REA.REPN,'ROI',ROIN);
% Internal Rate of Retourn (%):
TIRN=irr(FCASH1N);
% Internal Rate of Retourn (%):
TIRN=irr(REA.FCASHN.TOTAL(:,:,CASE-1))*100;
REA.REPN= setfield(REA.REPN,'TIR',TIRN);
% Simple Payback:                           (Years)
PBN= payback(FCASH1N);                      % Years
REA.REPN= setfield(REA.REPN,'PB',PBN);
% Payback with Discount:
PBDN= payback(FCASH11N);                     % Years
REA.REPN= setfield(REA.REPN,'PBD',PBDN);
% Economic Analysis:
ValueN=[PWORTHN;AWORTHN;ROIN;TIRN;PBN;PBDN];
Component = {'Present Worth ($)';'Anual Worth ($)';'Return of Investment (%)';'Internal Rate of Return (%)'; 'Simple Payback';'Discounted Payback'};
ECON = table(ValueN,'RowNames',Component);
REA.REPN= setfield(REA.REPN,'ECO',ECON);
% Net + Taxes:
NPC1NT=REA.NET.NPC(CASE);
NPCBNT=REA.NET.NPC(1);
PWORTHNT=NPCBNT-NPC1NT;
REA.REPNT= setfield(REA.REPNT,'PWORTH',PWORTHNT);
% Annual Worth ($):
AWORTHNT=PWORTHNT*CRF;
REA.REPNT= setfield(REA.REPNT,'AWORTH',AWORTHNT);
% Retorno de la Inversión ($):
ROINT=(FCASH1NT(1)-FCASH1NT(end))/(PL*FCASH1NT(1))*100;
REA.REPNT= setfield(REA.REPNT,'ROI',ROINT);
% Internal Rate of Retourn (%):
TIRNT=irr(FCASH1NT);
% Internal Rate of Retourn (%):
TIRNT=irr(REA.FCASHNT.TOTAL(:,:,CASE-1))*100;
REA.REPNT= setfield(REA.REPNT,'TIR',TIRNT);
% Simple Payback:                           (Years)
PBNT= payback(FCASH1NT);                      % Years
REA.REPNT= setfield(REA.REPNT,'PB',PBNT);
% Payback with Discount:
PBDNT= payback(FCASH11NT);                     % Years
REA.REPNT= setfield(REA.REPNT,'PBD',PBDNT);
% Economic Analysis:
ValueNT=[PWORTHNT;AWORTHNT;ROINT;TIRNT;PBNT;PBDNT];
Component = {'Present Worth ($)';'Anual Worth ($)';'Return of Investment (%)';'Internal Rate of Return (%)'; 'Simple Payback';'Discounted Payback'};
ECONT = table(ValueNT,'RowNames',Component);
REA.REPNT= setfield(REA.REPNT,'ECO',ECONT);
% Net + incentives:
NPC1C=REA.NET.NPCC(CASE);
NPCBC=REA.NET.NPCC(1);
PWORTHC=NPCBC-NPC1C;
REA.REPC= setfield(REA.REPC,'PWORTH',PWORTHC);
% Annual Worth ($):
AWORTHC=PWORTHC*CRF;
REA.REPC= setfield(REA.REPC,'AWORTH',AWORTHC);
% Retorno de la Inversión ($):
ROIC=(FCASH1C(1)-FCASH1C(end))/(PL*FCASH1C(1))*100;
REA.REPC= setfield(REA.REPC,'ROI',ROIC);
% Internal Rate of Retourn (%):
TIRC=irr(FCASH1C);
% Internal Rate of Retourn (%):
TIRC=irr(REA.FCASHC.TOTAL(:,:,CASE-1))*100;
REA.REPC= setfield(REA.REPC,'TIR',TIRC);
% Simple Payback:                           (Years)
PBC= payback(FCASH1C);                      % Years
REA.REPC= setfield(REA.REPC,'PB',PBC);
% Payback with Discount:
PBDC= payback(FCASH11C);                     % Years
REA.REPC= setfield(REA.REPC,'PBD',PBDC);
% Economic Analysis:
ValueC=[PWORTHC;AWORTHC;ROIC;TIRC;PBC;PBDC];
Component = {'Present Worth ($)';'Anual Worth ($)';'Return of Investment (%)';'Internal Rate of Return (%)'; 'Simple Payback';'Discounted Payback'};
ECOC = table(ValueC,'RowNames',Component);
REA.REPC= setfield(REA.REPC,'ECO',ECOC);
%--------------------------------------------------------------------------
% Net + Incentives + Taxes:
%--------------------------------------------------------------------------
NPC1CT=REA.NET.NPCC(CASE);
NPCBCT=REA.NET.NPCC(1);
PWORTHCT=NPCBCT-NPC1CT;
REA.REPCT= setfield(REA.REPCT,'PWORTH',PWORTHCT);
% Annual Worth ($):
AWORTHCT=PWORTHCT*CRF;
REA.REPCT= setfield(REA.REPCT,'AWORTH',AWORTHCT);
% Retorno de la Inversión ($):
ROICT=(FCASH1CT(1)-FCASH1CT(end))/(PL*FCASH1CT(1))*100;
REA.REPCT= setfield(REA.REPCT,'ROI',ROIC);
% Internal Rate of Retourn (%):
TIRCT=irr(FCASH1CT);
% Internal Rate of Retourn (%):
TIRCT=irr(REA.FCASHCT.TOTAL(:,:,CASE-1))*100;
REA.REPCT= setfield(REA.REPCT,'TIR',TIRCT);
% Simple Payback:                            (Years)
PBCT= payback(FCASH1CT);                      % Years
REA.REPCT= setfield(REA.REPC,'PB',PBCT);
% Payback with Discount:
PBDCT= payback(FCASH11CT);                     % Years
REA.REPCT= setfield(REA.REPCT,'PBD',PBDCT);
% Economic Analysis:
ValueCT=[PWORTHCT;AWORTHCT;ROICT;TIRCT;PBCT;PBDCT];
Component = {'Present Worth ($)';'Anual Worth ($)';'Return of Investment (%)';'Internal Rate of Return (%)'; 'Simple Payback';'Discounted Payback'};
ECOCT = table(ValueCT,'RowNames',Component);
REA.REPCT= setfield(REA.REPCT,'ECO',ECOCT);
%--------------------------------------------------------------------------
% Plots of Flow-Cash:
%--------------------------------------------------------------------------
% Counter plots:
if p1==1
np=WT.plot+1;
figure(np)
% CASHF: Cash flow with discount (mmd) (Gross Power)
% SCT: Presente neto (mmd)
% PL: Project Life (years)
Y1=bar(0:PL,CASHFG/1e6,'FaceColor',[0 .5 .5],'EdgeColor',[0 0 0],'LineWidth',2,'BarWidth',0.8);
xlim([0 PL]);
ylim([1.05*min(CASHFG/1e6) 1.2*max(CASHFG/1e6)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',16,'fontweight','light','LineWidth',2);
ylabel(SCG,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
xlabel('Número de Años','fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
h=legend([PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )'],'Location','southeast');
%h = legend('THD_v','Location','northeast','Orientation','horizontal');
%set(h,'LineWidth',2,'fontsize',14);
grid;
figure(np+1)
% CASHFN: Cash flow with discount (mmd) (Net power)
% SCT: Presente neto (mmd)
% PL: Project Life (years)
Y1=bar(0:PL,CASHFN/1e6,'FaceColor',[0 .5 .5],'EdgeColor',[0 0 0],'LineWidth',2,'BarWidth',0.8);
xlim([0 PL]);
ylim([1.05*min(CASHFN/1e6) 1.2*max(CASHFN/1e6)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',16,'fontweight','light','LineWidth',2);
ylabel(SCN,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
xlabel('Número de Años','fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
h=legend([PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )'],'Location','southeast');
%h = legend('THD_v','Location','northeast','Orientation','horizontal');
%set(h,'LineWidth',2,'fontsize',14);
grid;
figure(np+2)
% CASHF: Cash flow with discount (mmd)
% SCT: Presente neto (mmd)
% PL: Project Life (years)
% BC: By category,
% CAT: Category,
% CAT2: Category 2,
n=length(CAT2);
Y1=bar(1:length(BCG),BCG,'FaceColor',[0 .5 .5],'EdgeColor',[0 0 0],'LineWidth',2,'BarWidth',0.8);
xlim([0 n+1]);
ylim([round(min(BCG)) ceil(max(BCG))]);
% set(gca,'fontname','tahoma','fontsize',16,'fontweight','light','LineWidth',2);
set(gca,'xtick',1:length(CAT2),...
   'xticklabel',CAT2,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(SCT,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
xlabel(CAT1,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
h=legend([PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )'],'Location','northeast');
%h = legend('THD_v','Location','northeast','Orientation','horizontal');
%set(h,'LineWidth',2,'fontsize',14);
grid;
figure(np+3)
% CASHF: Cash flow with discount (mmd)
% SCT: Presente neto (mmd)
% PL: Project Life (years)
% BC: By category,
% CAT: Category,
% CAT2: Category 2,
n=length(CAT2);
Y1=bar(1:length(BCN),BCN,'FaceColor',[0 .5 .5],'EdgeColor',[0 0 0],'LineWidth',2,'BarWidth',0.8);
xlim([0 n+1]);
ylim([round(min(BCN)) ceil(max(BCN))]);
% set(gca,'fontname','tahoma','fontsize',16,'fontweight','light','LineWidth',2);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'xtick',1:length(CAT2),...
   'xticklabel',CAT2,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(SCT,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
xlabel(CAT1,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
h=legend([PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )'],'Location','northeast');
%title(h,[PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
%h = legend('THD_v','Location','northeast','Orientation','horizontal');
%set(h,'LineWidth',2,'fontsize',14);
grid;
%--------------------------------------------------------------------------
% Plot FCASH:
%--------------------------------------------------------------------------
% Plot of Acumulative Cash Flow ($):
figure(np+4)
% Gross:
FCASH_CASE1=FCASH1G;
FCASH_BASE1=FCASHBG;
FCASHD_CASE1=FCASH11G;
% Net:
FCASH_CASE2=FCASH1N;
FCASH_BASE2=FCASHBN;
FCASHD_CASE2=FCASH11N;
% Net + CEL:
FCASH_CASE3=FCASH1C;
FCASH_BASE3=FCASHBC;
FCASHD_CASE3=FCASH11C;
n=length(FCASH_CASE1);
% Nominal Cash FLow + Gross Power:
plot(0:n-1,FCASH_CASE1/1E6, 'LineStyle','-','LineWidth',3.5,'color',[0.5 0.5 0.5]);
hold on;
% Discounted cash flow + Gross Power:
plot(0:n-1,FCASHD_CASE1/1E6,'LineStyle','--','LineWidth',3,'color',[0.5 0.5 0.5]);
% Nominal + Pnet:
plot(0:n-1,FCASH_CASE2/1E6,'LineStyle','-','LineWidth',3,'color','blue');
% Descuento + Pnet:
plot(0:n-1,FCASHD_CASE2/1E6,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal + Pnet +CEL:
plot(0:n-1,FCASH_CASE3/1E6, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento + Pnet +CEL:
%plot(0:n-1,FCASHD_CASE3/1E6, 'LineStyle','--','LineWidth',3,'color',[0 0 0]);
plot(0:n-1,FCASHD_CASE3/1E6,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off;
% hold on;
% plot(0:n-1,FCASH_BASE/1E6,'LineStyle','-','LineWidth',3,'color',[0 01 1]);
% hold off
xlim([0 n-1]);
xlim([0 20]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['Flujo de Caja Acumulativo' newline '(mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
 % ylim([-150 200]);
xlabel('Año','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
 h=legend('Nominal, P_B_r_u_t_a','Descuento, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
 title(h,[PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
 %h.Font Size = 15;
 lgd.FontWeight = 'normal';
 %set(h,'LineStyle','-','LineWidth',2);
 grid
 %----------------------------------------------------------------------
 % Difference of Acumulative Cash Flow ($):
 %----------------------------------------------------------------------
 figure(np+5)
 % Gross:
 DCASH1=DIF1G;
 DCASHD1=DIFDG;
 % Net:
 DCASH2=DIF1N;
 DCASHD2=DIFDN;
 % Net+CEL:
 DCASH3=DIF1C;
 DCASHD3=DIFDC;
 % Length of DCASH1:
 n=length(DCASHD1);
 % Discounted cash flow + Gross Power:
 plot(0:n-1,DCASHD1/1E6,'LineStyle','-','LineWidth',3,'color',[0.5 0.5 0.5]);
 % plot(0:n-1,DCASH/1E6, 'LineStyle','-','LineWidth',3,'color',[1 0 0]);
 %plot(0:n-1,DCASHD1/1E6, 'LineStyle','-','LineWidth',3,'color',[1 0 0]);
 hold on;
 % Descuento + Pnet:
 plot(0:n-1,DCASHD2/1E6,'-b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
 % hold on;
 % plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
 % hold off
 %plot(0:n-1,DCASH3/1E6,'--ro','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
 plot(0:n-1,DCASHD3/1E6,'-gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
 %plot(0:n-1,DCASHD3/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
 hold off
 % hold on;
 % plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
 % hold off
 xlim([0 n-1]);
 title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
 set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
 ylabel(['Diferencia de Flujo Efectivo' newline ' Acumulativo (mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
 'HorizontalAlignment','center');
  % ylim([-150 200]);
  xlabel('Año','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
  'HorizontalAlignment','center');
  %h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
  h=legend('Descuento, P_B_r_u_t_a','Descuento, P_N_e_t_a','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
  title(h,[PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
  %h.Font Size = 15;
  lgd.FontWeight = 'normal';
  %set(h,'LineStyle','-','LineWidth',2);
  grid
  %----------------------------------------------------------------------
  % Plot of Acumulative Cash Flow ($):with ISR
  %----------------------------------------------------------------------
  figure(np+6)
  % Gross:
  FCASH_CASE1=FCASH1G;
  FCASH_BASE1=FCASHBG;
  FCASHD_CASE1=FCASH11G;
  % Net:
  FCASH_CASE2=FCASH1N;
  FCASH_BASE2=FCASHBN;
  FCASHD_CASE2=FCASH11N;
  % Net + Taxes:
  FCASE2=FCASH1NT;
  FCASED2=FCASH11NT;
  % Net+Incentives:
  FCASH_CASE3=FCASH1C;
  FCASH_BASE3=FCASHBC;
  FCASHD_CASE3=FCASH11C;
  % Net + Incentives+Taxes:
  FCASE3=FCASH1CT;
  FCASED3=FCASH11CT;
  n=length(FCASH_CASE1);
  % Nominal Cash FLow + Gross Power:
  plot(0:n-1,FCASH_CASE1/1E6, 'LineStyle','-','LineWidth',3.5,'color',[0.5 0.5 0.5]);
  hold on;
  % Discounted cash flow + Gross Power:
  plot(0:n-1,FCASHD_CASE1/1E6,'LineStyle','--','LineWidth',3,'color',[0.5 0.5 0.5]);
  % Nominal + Pnet:
  plot(0:n-1,FCASH_CASE2/1E6,'LineStyle','-','LineWidth',3,'color','blue');
  % Descuento + Pnet:
  plot(0:n-1,FCASHD_CASE2/1E6,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
  % Nominal + Pnet - ISR:
  %plot(0:n-1,FCASHD_CASE2/1E6,'--b','LineWidth',2.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
  plot(0:n-1,FCASE2/1E6,'LineStyle','-','LineWidth',3,'color','red');
  % Descuento + Pnet - ISR:
  plot(0:n-1,FCASED2/1E6,'--ro','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
  % Nominal + Pnet +CEL:
  plot(0:n-1,FCASH_CASE3/1E6, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
  % Descuento + Pnet +CEL:
  %plot(0:n-1,FCASHD_CASE3/1E6, 'LineStyle','--','LineWidth',3,'color',[0 0 0]);
  plot(0:n-1,FCASHD_CASE3/1E6,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
  % Nominal + Pnet + CEL - ISR:
  plot(0:n-1,FCASE3/1E6,'LineStyle','-','LineWidth',3,'color',[0 0 0]);
  % Descuento + Pnet + CEL - ISR:
  %plot(0:n-1,FCASED3/1E6,'LineStyle','--','LineWidth',3,'color',[0 0.5 0]);
  plot(0:n-1,FCASED3/1E6,'--kd','LineWidth',3,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
  % Descuento + Pnet +CEL:
  %   plot(0:n-1,FCASHD_CASE1/1E6,'LineStyle','-','LineWidth',3,'color',[0 0 1]); 
  %plot(0:n-1,FCASHD_CASE1/1E6,'-kx','LineWidth',2.5,'MarkerEdgeColor',[0 0.5 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',10);
  hold off;
  % hold on;
  % plot(0:n-1,FCASH_BASE/1E6,'LineStyle','-','LineWidth',3,'color',[0 01 1]);
  % hold off
  xlim([0 n-1]);
  xlim([0 20]);
  title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
  set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
  ylabel(['Flujo de Caja Acumulativo' newline '(mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
  'HorizontalAlignment','center');
  % ylim([-150 200]);
  xlabel('Año','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
  'HorizontalAlignment','center');
   h=legend('Nominal, P_B_r_u_t_a','Descuento, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (ISR)','Descuento, P_N_e_t_a (ISR)','Nominal, P_N_e_t_a (CEL)','Descuento,P_N_e_t_a (CEL)', 'Nominal, P_N_e_t_a (CEL, ISR)','Descuento, P_N_e_t_a (CEL, ISR)','Location','Northwest',...
       'NumColumns',2);
   title(h,[PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
   h.FontSize = 15;
   lgd.FontWeight = 'normal';
   %set(h,'LineStyle','-','LineWidth',2);
   grid
   %----------------------------------------------------------------------
   % Difference of Acumulative Cash Flow ($): with ISR
   %----------------------------------------------------------------------
   figure(np+7)
   % Gross:
   DCASH1=DIF1G;
   DCASHD1=DIFDG;
   % DCASH=DIFDGT;
   %    [xx1 yy1]=find(DCASHD1<0);
   %    [xx2 yy2]=find(DCASHD1>=0);
   %    DCASH=[DCASHD1(yy1) 0.7*DCASHD1(yy2)];
   % Net:
   DCASH2=DIF1N;
   DCASHD2=DIFDN;
   DCASH1=DIFDNT;
   %    [xx3 yy3]=find(DCASHD2<0);
   %    [xx4 yy4]=find(DCASHD2>=0);
   %    DCASH1=[DCASHD2(yy3) 0.7*DCASHD2(yy4)];
   % Net+CEL:
   DCASH3=DIF1C;
   DCASHD3=DIFDC;
   DCASH2=DIFDCT;
   %    [xx5 yy5]=find(DCASHD3<0);
   %    [xx6 yy6]=find(DCASHD3>=0);
   %    DCASH2=[DCASHD3(yy5) 0.7*DCASHD3(yy6)];
   n=length(DCASHD1);
   % Discounted cash flow + Gross Power:
   plot(0:n-1,DCASHD1/1E6,'LineStyle','-','LineWidth',3,'color',[0.5 0.5 0.5]);
   hold on;
   % Descuento + Pnet:
   plot(0:n-1,DCASHD2/1E6,'-b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
   % Descuento + Pnet - ISR:
   plot(0:n-1,DCASH1/1E6,'-ro','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
   % Descuento + Pnet +CEL:
   %plot(0:n-1,FCASHD_CASE3/1E6, 'LineStyle','--','LineWidth',3,'color',[0 0 0]);
   plot(0:n-1,DCASHD3/1E6,'-gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
   % Descuento + Pnet + CEL - ISR:
   %plot(0:n-1,FCASED3/1E6,'LineStyle','--','LineWidth',3,'color',[0 0.5 0]);
   plot(0:n-1,DCASH2/1E6,'-kd','LineWidth',3,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
   hold off
   % hold on;
   % plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
   % hold off
   xlim([0 n-1]);
   title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
   set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
   ylabel(['Diferencia de Flujo Efectivo' newline ' Acumulativo (mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
   'HorizontalAlignment','center');
   % ylim([-150 200]);
   xlabel('Año','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
   'HorizontalAlignment','center');
   %h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
   h=legend('Descuento, P_B_r_u_t_a','Descuento, P_N_e_t_a','Descuento, P_N_e_t_a (ISR)','Descuento,P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL, ISR)','Location','Northwest',...
       'NumColumns',1);
   %h=legend('Descuento, P_B_r_u_t_a menos ISR','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a menos ISR','Descuento con P_N_e_t_a','Location','Northwest');
   title(h,[PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
   %h.Font Size = 15;
   lgd.FontWeight = 'normal';
   %set(h,'LineStyle','-','LineWidth',2);
   grid
%--------------------------------------------------------------------------
% Update plot number:
%--------------------------------------------------------------------------
WT.plot=np+7;
end