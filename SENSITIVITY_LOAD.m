function [RSA,WT]=SENSITIVITY_LOAD(WF,WT,PEL,ED);

% This program carries the load sensitivity analysis of a wind farm:
% Inputs:
% P:         Structure of power profile
% PML:        Precio Marginal Local (US$/kW),
% GMDTH:      GMDTH Rates (US$/kW),
% LOAD1:      Load profile (kW) compatible with PML
% LOAD2:      Load profile (kW) compatible with GMDTH

% Outputs:
% Results of the Economic Sensitivity (RSA)
% RSA STRUCTURE:
%--------------------------------------------------------------------------
% Electricity rate:
%--------------------------------------------------------------------------
% Electricity rate: (1: PML, 2: GDMTH)
ERATE=ED.ERATE;
if ERATE==1
        PELERATE='PML';
else
        PELERATE='GDMTH';
end
%--------------------------------------------------------------------------
% Sensitivity of capital cost (USD/kW)
%--------------------------------------------------------------------------
% Variable capital costs
PLOAD=0:10:200;
NLOAD=length(PLOAD);
for i=1:NLOAD
    % ED.CT:
    %ED.CT=3;
    % Updating load percentage:
    ED.PLOAD=PLOAD(i);
    % Plot:
    ED.P1=0;
    % Gross Power:
    [REA, WT] = ECONOMIC_MODEL2(WF,WT,PEL,ED);
    ROIG(i)=REA.REPG.ROI;
    TIRG(i)=REA.REPG.TIR;
    PBG(i)=REA.REPG.PB;
    PBDG(i)=REA.REPG.PBD;
    NPCG(i)=REA.GROSS.NPC(end);
    COEG(i)=REA.GROSS.COE(end);
    % Economic Analysis with Annual Net Power:
    ROIN(i)=REA.REPN.ROI;
    TIRN(i)=REA.REPN.TIR;
    PBN(i)=REA.REPN.PB;
    PBDN(i)=REA.REPN.PBD;
    NPCN(i)=REA.NET.NPC(end);
    COEN(i)=REA.NET.COE(end);
    % Net power + CEL:
    ROIC(i)=REA.REPC.ROI;
    TIRC(i)=REA.REPC.TIR;
    PBC(i)=REA.REPC.PB;
    PBDC(i)=REA.REPC.PBD;
    NPCC(i)=REA.NET.NPCC(end);
    COEC(i)=REA.NET.COEC(end);
end
%--------------------------------------------------------------------------
% Results of Sensitivity Analysis:
%--------------------------------------------------------------------------
RSA=[];
RSA.PLOAD=[];
RSA.PLOAD= PLOAD;
RSA.ROI=[];
RSA.ROI= setfield(RSA.ROI,'ROIG',ROIG);
RSA.ROI= setfield(RSA.ROI,'ROIN',ROIN);
RSA.ROI= setfield(RSA.ROI,'ROIC',ROIC);
RSA.TIR=[];
RSA.TIR= setfield(RSA.TIR,'TIRG',TIRG);
RSA.TIR= setfield(RSA.TIR,'TIRN',TIRN);
RSA.TIR= setfield(RSA.TIR,'TIRC',TIRC);
RSA.COE=[];
RSA.COE= setfield(RSA.COE,'COEG',COEG);
RSA.COE= setfield(RSA.COE,'COEN',COEN);
RSA.COE= setfield(RSA.COE,'COEC',COEC);
RSA.NPC=[];
RSA.NPC= setfield(RSA.NPC,'NPCG',NPCG);
RSA.NPC= setfield(RSA.NPC,'NPCN',NPCN);
RSA.NPC= setfield(RSA.NPC,'NPCC',NPCC);
RSA.PB=[];
RSA.PB= setfield(RSA.PB,'PBG',PBG);
RSA.PB= setfield(RSA.PB,'PBN',PBN);
RSA.PB= setfield(RSA.PB,'PBC',PBC);
RSA.PB= setfield(RSA.PB,'PBDG',PBDG);
RSA.PB= setfield(RSA.PB,'PBDN',PBDN);
RSA.PB= setfield(RSA.PB,'PBDC',PBDC);
%----------------------------------------------------------------------
% Payback periods ($)
%----------------------------------------------------------------------
np=WT.plot+1;
figure(np)
% Nominal, TIRN:
plot(PLOAD,PBN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
plot(PLOAD,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(PLOAD,PBC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(PLOAD,PBDC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ymin=min([min(PBC) min(PBDN) min(PBDC) min(PBN)]);
ymax=max([max(PBC) max(PBDN) max(PBDC) max(PBN)]);
ylim([ymin ymax]);
xlim([min(PLOAD) max(PLOAD)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['Retorno de Inversión (Años)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('Carga (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
%h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
h=legend('Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northeast');
 title(h,[PELERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
 %h.Font Size = 15;
 lgd.FontWeight = 'normal';
 grid
 %
%----------------------------------------------------------------------
% Internal Rate of Return (%)
%----------------------------------------------------------------------
figure(np+1)
% Nominal, Pnet:
plot(PLOAD,TIRN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(PLOAD,TIRC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(CC,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
% hold off
ymin=min([min(TIRN) min(TIRC)]);
ymax=max([max(TIRN) max(TIRC)]);
ylim([ymin ymax]);
xlim([min(PLOAD) max(PLOAD)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['TIR (%)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('Carga (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
%h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
%h=legend('Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
h=legend('Nominal, P_N_e_t_a','P_N_e_t_a (CEL)','Location','Southeast');
title(h,[PELERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
%h.Font Size = 15;
lgd.FontWeight = 'normal';
grid
 %
%----------------------------------------------------------------------
% Return of Investment-ROI (%)
%----------------------------------------------------------------------
figure(np+2)
% Nominal, Pnet:
plot(PLOAD,ROIN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(PLOAD,ROIC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(CC,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ymin=min([min(ROIN) min(ROIC)]);
ymax=max([max(ROIN) max(ROIC)]);
ylim([ymin ymax]);
xlim([min(PLOAD) max(PLOAD)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['ROI (%)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('Carga (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
%h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
%h=legend('Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
h=legend('Nominal, P_N_e_t_a','P_N_e_t_a (CEL)','Location','Northwest');
title(h,[PELERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
%h.Font Size = 15;
lgd.FontWeight = 'normal';
grid
 %
%----------------------------------------------------------------------
% Levelized Cost of Energy-COE (USD/kW)
%----------------------------------------------------------------------
figure(np+3)
% Nominal, Pnet:
plot(PLOAD,COEN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(PLOAD,COEC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(CC,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ymin=min([min(COEC) min(COEN)]);
ymax=max([max(COEN) max(COEN)]);
ylim([ymin ymax]);
xlim([min(PLOAD) max(PLOAD)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['COE (USD/kW)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('Carga (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
%h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
%h=legend('Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
h=legend('Nominal, P_N_e_t_a','P_N_e_t_a (CEL)','Location','Northeast');
title(h,[PELERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
%h.Font Size = 15;
lgd.FontWeight = 'normal';
grid
%
%----------------------------------------------------------------------
% Net Present Cost-NPC (USD)
%----------------------------------------------------------------------
figure(np+4)
% Nominal, Pnet:
plot(PLOAD,NPCN/1E6,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(PLOAD,NPCC/1E6, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(CC,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ymin=min([min(NPCC)/1e6 min(NPCN)/1e6]);
ymax=max([max(NPCC)/1e6 max(NPCN)/1e6]);
ylim([ymin ymax]);
ylim([min(NPCC)/1e6 max(NPCN)/1e6]);
xlim([min(PLOAD) max(PLOAD)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['NPC (mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('Carga (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
%h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
%h=legend('Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
h=legend('Nominal, P_N_e_t_a','P_N_e_t_a (CEL)','Location','Southeast');
title(h,[PELERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
%h.Font Size = 15;
lgd.FontWeight = 'normal';
grid
%
%--------------------------------------------------------------------------
% Update plot number:
%--------------------------------------------------------------------------
WT.plot=np+4;