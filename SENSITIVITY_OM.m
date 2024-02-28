function [RSAOM,WT]=SENSITIVITY_OM(WF,WT,PEL,ED);
% This program carries a full sesitivity analysis of a wind farm:
% Inputs:
% P:          Structure of power profile
% PML:        Precio Marginal Local (US$/kW),
% GMDTH:      GMDTH Rates (US$/kW),
% LOAD1:      Load profile (kW) compatible with PML
% LOAD2:      Load profile (kW) compatible with GMDTH

% Outputs:
% Results of the Economic Sensitivity (RSAOM)
% RSAOM STRUCTURE:
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
OM=1:0.5:4;
NOM=length(OM);
for i=1:NOM
    % Updating capital cost:
    ED.OM=OM(i);
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
RSAOM=[];
RSAOM.OM=[];
RSAOM.OM= OM;
RSAOM.ROI=[];
RSAOM.ROI= setfield(RSAOM.ROI,'ROIG',ROIG);
RSAOM.ROI= setfield(RSAOM.ROI,'ROIN',ROIN);
RSAOM.ROI= setfield(RSAOM.ROI,'ROIC',ROIC);
RSAOM.TIR=[];
RSAOM.TIR= setfield(RSAOM.TIR,'TIRG',TIRG);
RSAOM.TIR= setfield(RSAOM.TIR,'TIRN',TIRN);
RSAOM.TIR= setfield(RSAOM.TIR,'TIRC',TIRC);
RSAOM.COE=[];
RSAOM.COE= setfield(RSAOM.COE,'COEG',COEG);
RSAOM.COE= setfield(RSAOM.COE,'COEN',COEN);
RSAOM.COE= setfield(RSAOM.COE,'COEC',COEC);
RSAOM.NPC=[];
RSAOM.NPC= setfield(RSAOM.NPC,'NPCG',NPCG);
RSAOM.NPC= setfield(RSAOM.NPC,'NPCN',NPCN);
RSAOM.NPC= setfield(RSAOM.NPC,'NPCC',NPCC);
RSAOM.PB=[];
RSAOM.PB= setfield(RSAOM.PB,'PBG',PBG);
RSAOM.PB= setfield(RSAOM.PB,'PBN',PBN);
RSAOM.PB= setfield(RSAOM.PB,'PBC',PBC);
RSAOM.PB= setfield(RSAOM.PB,'PBDG',PBDG);
RSAOM.PB= setfield(RSAOM.PB,'PBDN',PBDN);
RSAOM.PB= setfield(RSAOM.PB,'PBDC',PBDC);
%----------------------------------------------------------------------
% Payback periods ($)
%----------------------------------------------------------------------
np=WT.plot+1;
figure(np)
% Nominal, TIRN:
plot(OM,PBN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(OM,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
plot(OM,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(OM,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(OM,PBC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(OM,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(OM,PBDC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(PBC) max(PBDN)]);
xlim([min(OM) max(OM)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['Retorno de Inversión (Años)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('O&M (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
%h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
h=legend('Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
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
plot(OM,TIRN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(OM,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(OM,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(OM,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(OM,TIRC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(OM,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(OM,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(TIRN) max(TIRC)]);
xlim([min(OM) max(OM)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['TIR (%)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('O&M (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
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
% Return of Investment-ROI (%)
%----------------------------------------------------------------------
figure(np+2)
% Nominal, Pnet:
plot(OM,ROIN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(OM,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(OM,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(OM,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(OM,ROIC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(OM,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(OM,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(ROIN) max(ROIC)]);
xlim([min(OM) max(OM)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['ROI (%)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('O&M (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
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
% Levelized Cost of Energy-COE (USD/kW)
%----------------------------------------------------------------------
figure(np+3)
% Nominal, Pnet:
plot(OM,COEN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(OM,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(OM,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(OM,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(OM,COEC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(OM,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(OM,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(COEC) max(COEN)]);
xlim([min(OM) max(OM)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['COE (USD/kW)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('O&M (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
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
% Net Present Cost-NPC (USD)
%----------------------------------------------------------------------
figure(np+4)
% Nominal, Pnet:
plot(OM,NPCN/1E6,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(OM,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(OM,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(OM,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(OM,NPCC/1E6, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(OM,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(OM,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(NPCC/1E6) max(NPCN/1E6)]);
xlim([min(OM) max(OM)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['NPC (mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('O&M (%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
%h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
%h=legend('Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
h=legend('Nominal, P_N_e_t_a','P_N_e_t_a (CEL)','Location','Northwest');
title(h,[PELERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
%h.Font Size = 15;
lgd.FontWeight = 'normal';
grid
%
%--------------------------------------------------------------------------
% Update plot number:
%--------------------------------------------------------------------------
WT.plot=np+4;