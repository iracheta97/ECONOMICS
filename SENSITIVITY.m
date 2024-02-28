function [RSA,WT]=SENSITIVITY(WF,WT,PEL,ED);

% This program carries a full sesitivity analysis of a wind farm:
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
CC=2000:500:6000;
NCC=length(CC);
for i=1:NCC
    % Updating capital cost:
    ED.CC=CC(i);
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
RSA.CC=[];
RSA.CC= CC;
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
plot(CC,PBN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(CC,PBC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(CC,PBDC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(PBC) max(PBN)]);
xlim([min(CC) max(CC)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['Retorno de Inversión (Años)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('USD/kW','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
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
plot(CC,TIRN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(CC,TIRC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(CC,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(TIRN) max(TIRC)]);
xlim([min(CC) max(CC)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['TIR (%)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('USD/kW','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
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
plot(CC,ROIN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(CC,ROIC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(CC,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(ROIN) max(ROIC)]);
xlim([min(CC) max(CC)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['ROI (%)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('USD/kW','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
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
plot(CC,COEN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(CC,COEC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(CC,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(COEC) max(COEN)]);
xlim([min(CC) max(CC)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['COE (USD/kW)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('USD/kW','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
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
plot(CC,NPCN/1E6,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
%plot(CC,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(CC,NPCC/1E6, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Descuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
%plot(CC,TIRC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
ylim([min(NPCC)/1e6 max(NPCN)/1e6]);
xlim([min(CC) max(CC)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['NPC (mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('USD/kW','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
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