function [COST,WP,DF,FCASH,CRF,POWER] = ECONOMY(WF,WT,POWER,EP,LOAD,ED)

% This program evaluates the OPERATING COSTS of a wind farm:

% Inputs:
% WF.- Wind Farm,
% WT.- Wind Turbine,
% POWER.- Vector of Annual Energy Profile (kWh) (8760 Data);
% EP.- Vector of Electricity Prices USD/kW (8760 Data),
% LOAD.-Vector of Load Profile kW (8760 Data),
% ED.CC: Capital Cost (USD),
% ED.OM: Operation and Maintenance (USD),
% ED.PL: Project Life,
% ED.R:  Real Interest

% Outputs:
% COST STRUCTURE
% COST.CC.DATA.- Capital Cost (USD)
% COST.OP.DATA.-Operating Costs(USD)
% COST.OMT.DATA.- Operation and Maintenance Costos (USD),
% WP.- Wind Production Data Structure (kW/yr),
% DF.- Discount Factor (DF),
% FCASH.- Costs with Discount Factor (USD).
% CRF.- Capital Recovery Factor.
% VA.- Present Value,
% VAN.- Net Present Value,
% POWER.- Electricity Production of a Single Turbine
% Samples per hour:
F=length(POWER)/8760;
% Production of a Single Wind Farm (kW):
POWER=POWER;

% Capital Recovery Factor (CRF):
R=ED.R;                             % Real Interest;
PL=ED.PL;                           % Project Life;
CRF=(R/100)*power((1+R/100),PL)/(power(1+R/100,PL)-1);

% Operating Cost ($/kW) and Energy Production (kWh)/yr:
NWT=WF.N;
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
    % Power Grid:
%     length(EP)
%     length(POWER)
%     length(LOAD)
%     length(F)
    GRID(i,:)=(sum(EP.*(POWER*(i-1)-LOAD)))/F;               % USD
    % Total Fuel Cost:
    FUEL(i,:)=0;                                             % USD
    % Total Annualized Maintenance Cost
    OP(i,:)= (OMT(i,:)-GRID(i,:));                           % USD
    % Total Annualized Cost:                                 % USD
    TAC(i,:)=OP(i,:)+TACC(i,:);                              % USD
    % Wind Production (kWh/yr):
    WPROD(i,:)=(i-1)*sum(POWER)/F;                           % kWh/yr
    % Grid Purchases (kWh/yr);
    GP=(i-1)*POWER-LOAD;                                    % kW
    GPUR(i,:)=abs(sum(GP(find(GP<0))))/F;                   % kW/yr
    % Grid Sales (kWh/yr):
    GSAL(i,:)=abs(sum(GP(find(GP>0))))/F;                   % kW/yr
    % Grid Net Purchases (kWh/yr):
    GNP(i,:)= GPUR(i,:)-GSAL(i,:);                           % kW/yr
    % Total Electrical Production (kW/yr):
    GTEP(i,:)=WPROD(i,:)+GPUR(i,:);                          % kW/yr
    % AC Primary Load Served (kW/yr)
    PACL(i,:)=sum(LOAD)/F;                                   % kW/yr
    % Renewable Fraction (%):
    if i==1
        RF(i,:)=0;                                           % %
    else
        RF(i,:)=100*WPROD(i,:)/GTEP(i,:);                    % %
    end
    % NPC:
    NPC(i,:)=TAC(i,:)/CRF;                                  % USD
    % Levelized Cost of Energy (USD:
    COE(i,:)=TAC(i,:)/GTEP(i,:);                             % USD/kW
end
GRID
% Discount Factor and Cash Flow: 
CAF=[];
WFARM=zeros(5,PL+1,NWT+1);
PGRID=zeros(5,PL+1,NWT+1);
% With Discount:
WFARMD=zeros(5,PL+1,NWT+1);
PGRIDD=zeros(5,PL+1,NWT+1);
for i=1:PL+1
    DF(i,:)=1/power((1+R/100),i-1);
    if i==1
        WFARM(1,i,:)=-CCT;                 % USD
        WFARMD(1,i,:)=-CCT;                % USD
    elseif i>1
        % O&M:
        WFARM(3,i,:)=-OMT;                   % USD
        WFARMD(3,i,:)=-DF(i,:)*OMT;          % USD
        % Operating:
        PGRID(3,i,:)=GRID;                   % USD
        PGRIDD(3,i,:)=DF(i,:)*GRID;          % USD
    end
end

% Breakdown of Costs:
% Capital Cost:
COST=[];
COST= setfield(COST,'AGS',AGS);              % Number of Wind Turbines
COST= setfield(COST,'CC',CCT);
COST= setfield(COST,'TACC',TACC);            % Total Annualized Capital Cost (USD)
COST= setfield(COST,'TARC',TARC);            % Total Annualized Replacement Cost (USD)
COST= setfield(COST,'OM',OMT);
COST= setfield(COST,'FUEL',FUEL);            % Fuel Cost (USD)
COST= setfield(COST,'GRID',GRID);
COST= setfield(COST,'OP',OP);
COST= setfield(COST,'NPC',NPC);              % Net Present Cost (USD)
COST= setfield(COST,'TAC',TAC);              % Total Annualized Cost USD
COST= setfield(COST,'COE',COE);              % Levelized Cost of Energy (USD/kWh)
COST= setfield(COST,'UNITS','U0.S Dollar');
% Wind Production:
WP=[];
WP=setfield(WP,'WPROD',WPROD);
WP=setfield(WP,'GPUR',GPUR);                 % Grid Purchases
WP=setfield(WP,'GSAL',GSAL);                 % Grid Sales
WP=setfield(WP,'GNP',GNP);                   % Grid Net Purchase
WP=setfield(WP,'GTEP',GTEP);                 % Total Electricity Protuction
WP=setfield(WP,'PACL',PACL);                 % AC Primary Load Served (kW/yr)
WP=setfield(WP,'UNITS','kWh/yr');            % Units (kWh/yr)
WP=setfield(WP,'RF',RF);                     % Renewable Fraction (%)

% Total Flow Cash (USD):
TOTAL=sum(WFARM+PGRID,1);                      % USD
TOTALD=sum(WFARMD+PGRIDD,1);                   % USD
VA(:,1)=sum(TOTALD);                           % USD
VAN=VA-CCT;
% Flow Cash:
FCASH=[];
FCASH= setfield(FCASH,'WFARM',WFARM);
FCASH= setfield(FCASH,'PGRID',PGRID);
FCASH= setfield(FCASH,'TOTAL',TOTAL);
FCASH= setfield(FCASH,'WFARMD',WFARMD);
FCASH= setfield(FCASH,'PGRIDD',PGRIDD);
FCASH= setfield(FCASH,'TOTALD',TOTALD);
FCASH= setfield(FCASH,'UNITS','US Dollar');

% OPTIMIZATION RESULTS:
[B,I]=sort(NPC);
H1={'Grid', 'Turbines', 'Total Capital Cost','Tot Ann. Cap Cost', 'Tot. Ann. Repl. Cost',...
    'Total O&M Cost', 'Total Fuel Cost', 'Total Ann. Cost', 'Operating Cost',...
    'Total NPC', 'COE','Wind Production','Grid Purachases', 'Grid Sales',...
    'Grid Net Purchases', 'Tot. Electrical Production', 'AC Primary Load Served'...
    'Renewable Fraction'};
H2={'' '' '($/yr)' '($/yr)' '($/yr)'...
    '($/yr)' '($/yr)' '($/yr)' '($/yr)'...
    '($)' '($/kWh)' '(kWh/yr)' '(kWh/yr)' '(kWh/yr)'...
    '(kWh/yr)' '(kWh/yr)' '(kWh/yr)' '(%)'};
class=[G(I) AGS(I) CCT(I) TACC(I) TARC(I)...
       OMT(I) FUEL(I) TAC(I) OP(I)...
       NPC(I) COE(I) WPROD(I) GPUR(I) GSAL(I)...
       GNP(I) GTEP(I) PACL(I) RF(I)];
sheet=1;
% Write an Excel file:
xlswrite('OPTIMIZATION',H1,'OPTIMIZATION','A1');
xlswrite('OPTIMIZATION',H2,'OPTIMIZATION','A2');
xlswrite('OPTIMIZATION',class,'OPTIMIZATION','A3');