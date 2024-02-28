function [OPT REP TOTAL ECO WT] = EREPORT(WF,WT,COST,FCASH,POWER,LOAD,CRF,ED,p1)

% This functions provide the economic results

% Inputs:
% WF:       Wind Farm Data,
% WT:       Wind Turbine,
% COST:     Structure Array of Costs,
% FCASH:    Structure of Cash Flows,
% POWER:    Wind Production (kW),
% LOAD:     Load Consumption (kW),
% CRF:      Capital Recovery Factor,
% ED:       Economic Data,
% p1.- Plot: 1='yes' or 0='no'

% Outputs:
% OPT:      Structure Data of Economic Results,
% REP:      Report Data,
% TOTAL:    Breakdown of Costs (USD),
% ECO:      Economic Results,
% WT:       Update WT.plot

% Turbine Type:

%OPTIM = {'GRID'; 'WIND TURBINE'; 'Initial Capital (Mill. USD)';'Operating ($/yr)','TOTAL NPC','COE ($/kWh)','Ren. Frac.'};
% Capital Cost (USD/kW):
Cap=COST.CC;
% Number of Turbines
Turb=[0:WF.N]';
% Grid Costs (USD/kW):
Grid=0*COST.CC+1;
% Operating Costs (USD/kW):
Operating=COST.OP;
% Operation & Maintenance Cost (USD/kW):
OMT=-COST.OM;
% Sales Costs (USD/kW):
GRID_SALES=COST.GRID;
% Net Present Cost (USD/kW):
NPC=COST.NPC;
% Table of Results:
OPT= table(Grid,Turb,Cap,OMT, GRID_SALES, Operating,NPC);
%--------------------------------------------------------------------------
% Production of Electricity:
%--------------------------------------------------------------------------
PROD=[];CONS=[];QUAN=[];REP=[];
% Samples per Hour:
EF=length(POWER)/8760;
% Wind Turbine:
SPW=sum(POWER)/EF;                        % Electriciy Production
%--------------------------------------------------------------------------
% Grid Purchases:
%--------------------------------------------------------------------------
GPUR=POWER-LOAD;                          % kW
SPG=abs(sum(GPUR(find(GPUR<=0))))/EF;     % kW/yr
TOTAL=SPW+SPG;                            % kW
PROD= setfield(PROD,'WT',SPW);
PROD= setfield(PROD,'WTP',100*SPW/TOTAL);             % %
PROD= setfield(PROD,'GP',SPG);                        % kW
PROD= setfield(PROD,'GPP',100*SPG/TOTAL);             % %
PROD= setfield(PROD,'TOTAL',TOTAL);
PROD= setfield(PROD,'UNITS','kWh/yr');

%--------------------------------------------------------------------------
% Grid Sales:
%--------------------------------------------------------------------------
SCONS=sum(LOAD)/EF;                                 % Load Consuption
GS=abs(sum(GPUR(find(GPUR>=0))));                   % kW/yr
TOTAL=GS+SCONS; 
CONS= setfield(CONS,'LOAD',SCONS);                  % kW
CONS= setfield(CONS,'LOADP',100*SCONS/TOTAL);       % kW
CONS= setfield(CONS,'GS',GS);                       % kW
CONS= setfield(CONS,'GSP',100*GS/TOTAL);            % %
CONS= setfield(CONS,'TOTAL',(SCONS+GS));            % kW
CONS= setfield(CONS,'UNITS','kWh/yr');
%--------------------------------------------------------------------------
% Quantity:
%--------------------------------------------------------------------------
QUAN= setfield(QUAN,'RF',100*SPW/TOTAL);
%--------------------------------------------------------------------------
% Summary Costs:
%--------------------------------------------------------------------------
CASE=ED.CASE;
SUMCOST=FCASH.TOTAL(:,:,CASE);
Component = {'Turbine';'Grid';'System'};
%--------------------------------------------------------------------------
% Summary Cost (USD):
SC=ED.SC;
% Project Life (Years):
PL=ED.PL;
% Summary costs:
if SC==1                                    % Present Net:
    Capital=[FCASH.WFARM(1,1,CASE)/1e6;0];
    Capital= [Capital; sum(Capital)];
    Replacement=[sum(FCASH.WFARM(2,2:end,CASE))/1e6;0];
    Replacement=[Replacement; sum(Replacement)];
    Operating= [sum(FCASH.WFARMD(3,:,CASE))/1e6;sum(FCASH.PGRIDD(3,:,CASE))/1e6];
    Operating= [Operating; sum(Operating)];
    Fuel=[sum(FCASH.WFARM(4,:,CASE))/1e6;0];
    Fuel= [Fuel; sum(Fuel)];
    Salvage=[sum(FCASH.WFARM(5,:,CASE));0];
    Salvage=[Salvage; sum(Salvage)];
    %SCT='Present Net (Millions $)';
    SCT='Presente Neto (mdd)';
elseif SC==2                               % Annualized
    Capital=[FCASH.WFARM(1,1,CASE)*CRF(end)/1e6;0];
    Capital= [Capital; sum(Capital)];
    Replacement=[sum(FCASH.WFARM(2,2:end,CASE))/1e6;0];
    Replacement=[Replacement; sum(Replacement)];
    Operating= [sum(FCASH.WFARM(3,:,CASE)/PL)/1e6;sum(FCASH.PGRID(3,:,CASE)/PL)/1e6];
    Operating= [Operating; sum(Operating)];
    Fuel=[sum(FCASH.WFARM(4,:,CASE))/1e6;0];
    Fuel= [Fuel; sum(Fuel)];
    Salvage=[sum(FCASH.WFARM(5,:,CASE));0];
    Salvage=[Salvage; sum(Salvage)];
    %SCT='Annualized Value (Millions $)';
    SCT='Valor Anualizado (mdd)';
end
T1=[Capital Replacement Operating Fuel Salvage];
TOTAL= Capital+Replacement+Operating+Fuel+Salvage;
REP= setfield(REP,'SCT',SCT);
REP= setfield(REP,'T1',T1);
%--------------------------------------------------------------------------
% By Category:
%--------------------------------------------------------------------------
CAT=ED.CAT;
if CAT==1       % By Component:
   BC=TOTAL(1:end-1);
   %CAT1='By Component';
   CAT1='Por Componente';
   %CAT2=['WIND TURBINE' 'GRID'];
   CAT2={'Turbina' 'Red Eléctrica'};
elseif CAT==2   % By Cost Type:
   BC=T1(end,:);
   %CAT1='By Cost-Type';
   CAT1='Por Tipo de Costo';
   CAT2={'Capital' 'Reemplazo' 'Operación' 'Combustible' 'Salvamento'};
else
    display('error');
end
REP= setfield(REP,'BC',BC);
REP= setfield(REP,'CAT',CAT1);
REP= setfield(REP,'CAT2',CAT2);
%--------------------------------------------------------------------------
% Millions of USD:
%--------------------------------------------------------------------------
T = table(Capital, Replacement, Operating, Fuel, Salvage, TOTAL,...
    'RowNames',Component);
%--------------------------------------------------------------------------
% Cash Flow: (Totals) & Acumulative Cash Flow ($):
%--------------------------------------------------------------------------
CF=ED.CF;
if CF==1  % Nominal
    CASHF=2;
    SC='Flujo de Caja Nominal (mdd)';
    FCASH1=cumsum(FCASH.TOTAL(:,:,CASE));
    FCASHB=cumsum(FCASH.TOTAL(:,:,1));
    CASHF=FCASH.TOTAL(:,:,CASE);
else  % Discount
    CASHF=FCASH.TOTALD(:,:,CASE);
    SC='Flujo de Caja con Descuento (mdd)';
    FCASH1=cumsum(FCASH.TOTALD(:,:,CASE));
    FCASHB=cumsum(FCASH.TOTALD(:,:,1));
    CASHF=FCASH.TOTALD(:,:,CASE);
end
REP= setfield(REP,'SC',SC);
REP= setfield(REP,'CASHF',CASHF);
% Acumulative Cash Flow ($):
FCASH1=cumsum(FCASH.TOTAL(:,:,CASE));
FCASHB=cumsum(FCASH.TOTAL(:,:,1));
FCASH11=cumsum(FCASH.TOTALD(:,:,CASE));
FCASHBB=cumsum(FCASH.TOTALD(:,:,1));
DIF1=FCASH1-FCASHB;
DIFD=FCASH11-FCASHBB;
REP= setfield(REP,'FCASH_CASE',FCASH1);
REP= setfield(REP,'FCASH_BASE',FCASHB);
REP= setfield(REP,'FCASHD_CASE',FCASH11);
REP= setfield(REP,'FCASHD_BASE',FCASHBB);
REP= setfield(REP,'DCASH',DIF1);
REP= setfield(REP,'DCASHD',DIFD);
% Present Worth ($):
NPC1=COST.NPC(CASE);
NPCB=COST.NPC(1);
PWORTH=NPCB-NPC1;
REP= setfield(REP,'PWORTH',PWORTH);
% Annual Worth ($):
AWORTH=PWORTH*CRF;
REP= setfield(REP,'AWORTH',AWORTH);
% Retorno de la Inversión ($):
ROI=(FCASH1(1)-FCASH1(end))/(PL*FCASH1(1))*100;
REP= setfield(REP,'ROI',ROI);
% Internal Rate of Retourn (%):
TIR=irr(FCASH1);
% Internal Rate of Retourn (%):
TIR=irr(FCASH.TOTAL(:,:,CASE-1))*100;
REP= setfield(REP,'TIR',TIR);
% Simple Payback:                           (Years)
PB= payback(FCASH1);                        % Years
REP= setfield(REP,'PB',PB);
% Payback with Discount:
PBD= payback(FCASH11);                      % Years
REP= setfield(REP,'PBD',PBD);
% Economic Analysis:
Value=[PWORTH;AWORTH;ROI;TIR;PB;PBD];
Component = {'Present Worth ($)';'Anual Worth ($)';'Return of Investment (%)';'Internal Rate of Return (%)'; 'Simple Payback';'Discounted Payback'};
ECO = table(Value,'RowNames',Component);
%--------------------------------------------------------------------------
% Plots of Flow-Cash:
%--------------------------------------------------------------------------
% Counter plots:
if p1==1
np=WT.plot+1;
figure(np)
% CASHF: Cash flow with discount (mmd)
% SCT: Presente neto (mmd)
% PL: Project Life (years)
Y1=bar(0:PL,CASHF/1e6,'FaceColor',[0 .5 .5],'EdgeColor',[0 0 0],'LineWidth',2,'BarWidth',0.8);
xlim([0 PL]);
ylim([1.05*min(CASHF/1e6) 1.2*max(CASHF/1e6)]);
set(gca,'fontname','tahoma','fontsize',16,'fontweight','light','LineWidth',2);
ylabel(SC,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
xlabel('Número de Años','fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
%h = legend('THD_v','Location','northeast','Orientation','horizontal');
%set(h,'LineWidth',2,'fontsize',14);
grid;
figure(np+1)
% CASHF: Cash flow with discount (mmd)
% SCT: Presente neto (mmd)
% PL: Project Life (years)
% BC: By category,
% CAT: Category,
% CAT2: Category 2,
n=length(CAT2);
Y1=bar(1:length(BC),BC,'FaceColor',[0 .5 .5],'EdgeColor',[0 0 0],'LineWidth',2,'BarWidth',0.8);
xlim([0 n+1]);
ylim([round(min(BC)) ceil(max(BC))]);
% set(gca,'fontname','tahoma','fontsize',16,'fontweight','light','LineWidth',2);
set(gca,'xtick',1:length(CAT2),...
   'xticklabel',CAT2,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(SCT,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
xlabel(CAT,'fontsize',18,'fontname','tahoma','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
%h = legend('THD_v','Location','northeast','Orientation','horizontal');
%set(h,'LineWidth',2,'fontsize',14);
grid;
%--------------------------------------------------------------------------
% Update plot number:
%--------------------------------------------------------------------------
WT.plot=np+1;
end



