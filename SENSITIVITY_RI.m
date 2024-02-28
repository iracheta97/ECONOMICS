function [RSARI]=SENSITIVITY_RI(WF,WT,PEL,ED);
% This program carries a full sesitivity analysis of a wind farm:
% Inputs:
% P:         Structure of power profile
% PML:        Precio Marginal Local (US$/kW),
% GMDTH:      GMDTH Rates (US$/kW),
% LOAD1:      Load profile (kW) compatible with PML
% LOAD2:      Load profile (kW) compatible with GMDTH

% Outputs:
% Results of the Economic Sensitivity (RSARI)
% RSARI STRUCTURE:

%--------------------------------------------------------------------------
% Sensitivity of Real Interest (USD/kW)
%--------------------------------------------------------------------------
% Variable real interest
R=3:0.5:6;
NR=length(R);
for i=1:NR
    % Updating real interest:
    ED.R=R(i);
    % Plot:
    ED.P1=0;
    % Gross Power:
    [REA, WT] = ECONOMIC_MODEL(WF,WT,PEL,ED);
    ROIG(i)=REA.REPG.ROI;
    TIRG(i)=REA.REPG.TIR;
    PBG(i)=REA.REPG.PB;
    PBDG(i)=REA.REPG.PBD;
    % Economic Analysis with Annual Net Power:
    ROIN(i)=REA.REPN.ROI;
    TIRN(i)=REA.REPN.TIR;
    PBN(i)=REA.REPN.PB;
    PBDN(i)=REA.REPN.PBD;
    % Net power + CEL:
    ROIC(i)=REA.REPC.ROI;
    TIRC(i)=REA.REPC.TIR;
    PBC(i)=REA.REPC.PB;
    PBDC(i)=REA.REPC.PBD;
end
%--------------------------------------------------------------------------
% Results of Sensitivity Analysis:
%--------------------------------------------------------------------------
RSARI=[];
RSARI.ROI=[];
RSARI.ROI= setfield(RSARI.ROI,'ROIG',ROIG);
RSARI.ROI= setfield(RSARI.ROI,'ROIN',ROIN);
RSARI.ROI= setfield(RSARI.ROI,'ROIC',ROIC);
RSARI.TIR=[];
RSARI.TIR= setfield(RSARI.TIR,'TIRG',TIRG);
RSARI.TIR= setfield(RSARI.TIR,'TIRN',TIRN);
RSARI.TIR= setfield(RSARI.TIR,'TIRC',TIRC);
RSARI.PB=[];
RSARI.PB= setfield(RSARI.PB,'PBG',PBG);
RSARI.PB= setfield(RSARI.PB,'PBN',PBN);
RSARI.PB= setfield(RSARI.PB,'PBC',PBC);
RSARI.PB= setfield(RSARI.PB,'PBDG',PBDG);
RSARI.PB= setfield(RSARI.PB,'PBDN',PBDN);
RSARI.PB= setfield(RSARI.PB,'PBDC',PBDC);
%----------------------------------------------------------------------
% Payback periods ($)
%----------------------------------------------------------------------
np=WT.plot+3;
figure(np)
% Nominal, Pnet:
plot(R,PBN,'LineStyle','-','LineWidth',3,'color','blue');
% hold on;
% plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
% hold off
hold on;
% Descuento, Pnet:
%plot(CC,PBDN,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
plot(R,PBDN,':b+','LineWidth',3.5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',12);
% Nominal, Incentives, Pnet:
%plot(CC,PBC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(R,PBC, 'LineStyle','-','LineWidth',3,'color',[0 0.5 0]);
% Des%cuento, Incentives, Pnet:
%plot(CC,PBDC,'LineStyle','-.','LineWidth',3,'color',[0 0.5 1]);
plot(R,PBDC,':gx','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.49 1 .63],'MarkerSize',12);
hold off
% hold on;
% plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
% hold off
% ylim([min(PBN) max(PBN)]);
xlim([min(R) max(R)]);
title([PEL.WBASE,', ', PEL.WT],'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
ylabel(['Retorno de Inversión (Años)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
'HorizontalAlignment','center');
% ylim([-150 200]);
xlabel('Tasa de interés real(%)','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
'HorizontalAlignment','center');
%h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
h=legend('Nominal, P_N_e_t_a','Descuento, P_N_e_t_a','Nominal, P_N_e_t_a (CEL)','Descuento, P_N_e_t_a (CEL)','Location','Northwest');
 title(h,[PEL.ERATE ' ( ' num2str(PEL.yy,'%.0f') ' )']);
 %h.Font Size = 15;
 lgd.FontWeight = 'normal';
 grid
 %