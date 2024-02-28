function [WT] = PLOT_FCASH(WT,REP1,REP2,p1)

% This program plots the Cash-Flow of different economic cases:

% Inputs:
% WT:    Wind Turbine,
% REP1.- Results of Economic Payback, Case 1,
% REP2.- Results of Economic Payback, Case 2.
% p1.-   Plot: 1='yes' or 0='no'

% Outputs:
% WT.- Wind Turbine,

%--------------------------------------------------------------------------
% Plot Cash-Flows:
%--------------------------------------------------------------------------
if p1==1
    % Number of plots:
    np=WT.plot+1;
    %----------------------------------------------------------------------
    % Plot of Acumulative Cash Flow ($):
    %----------------------------------------------------------------------
    figure(np)
    FCASH_CASE1=REP1.FCASH_CASE;FCASH_CASE2=REP2.FCASH_CASE;
    FCASH_BASE1=REP1.FCASH_BASE;FCASH_BASE2=REP2.FCASH_BASE;
    FCASHD_CASE1=REP1.FCASHD_CASE;FCASHD_CASE2=REP2.FCASHD_CASE;
    n=length(FCASH_CASE1);
    plot(0:n-1,FCASH_CASE1/1E6, 'LineStyle','-','LineWidth',3,'color',[1 0 0]);
    hold on;
    plot(0:n-1,FCASH_CASE2/1E6,'LineStyle',':','LineWidth',3,'color',[0 0 0]);
    plot(0:n-1,FCASHD_CASE1/1E6,'LineStyle','-','LineWidth',3,'color',[0 0 1]);
    plot(0:n-1,FCASHD_CASE2/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
    hold off;
    % hold on;
    % plot(0:n-1,FCASH_BASE/1E6,'LineStyle','-','LineWidth',3,'color',[0 01 1]);
    % hold off
    xlim([0 n-1]);
    xlim([0 20]);
    set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
    ylabel(['Flujo de Caja Acumulativo' newline '(mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
    % ylim([-150 200]);
    xlabel('Año','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
    h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento, P_N_e_t_a','Location','Northwest');
    %h.Font Size = 15;
    lgd.FontWeight = 'normal';
    %set(h,'LineStyle','-','LineWidth',2);
    grid
    %----------------------------------------------------------------------
    % Difference of Acumulative Cash Flow ($):
    %----------------------------------------------------------------------
    figure(np+1)
    DCASH1=REP1.DCASH;DCASH2=REP2.DCASH;
    DCASHD1=REP1.DCASHD;DCASHD2=REP2.DCASHD;
    n=length(DCASHD1);
    % plot(0:n-1,DCASH/1E6, 'LineStyle','-','LineWidth',3,'color',[1 0 0]);
    plot(0:n-1,DCASHD1/1E6, 'LineStyle','-','LineWidth',3,'color',[1 0 0]);
    % hold on;
    % plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
    % hold off
    hold on;
    plot(0:n-1,DCASHD2/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
    hold off
    % hold on;
    % plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
    % hold off
    xlim([0 n-1]);
    set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
    ylabel(['Diferencia de Flujo Efectivo' newline ' Acumulativo (mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
    % ylim([-150 200]);
    xlabel('Año','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
    %h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
    h=legend('Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
    %h.Font Size = 15;
    lgd.FontWeight = 'normal';
    %set(h,'LineStyle','-','LineWidth',2);
    grid
    %----------------------------------------------------------------------
    % Plot of Acumulative Cash Flow ($):with ISR
    %----------------------------------------------------------------------
    figure(np+2)
    FCASH_CASE1=REP1.FCASH_CASE;FCASH_CASE2=REP2.FCASH_CASE;
    FCASH_BASE1=REP1.FCASH_BASE;FCASH_BASE2=REP2.FCASH_BASE;
    FCASHD_CASE1=REP1.FCASHD_CASE;FCASHD_CASE2=REP2.FCASHD_CASE;
    n=length(FCASH_CASE1);
    [xx1 yy1]=find(FCASH_CASE2<0);
    [xx2 yy2]=find(FCASH_CASE2>=0);
    FCASE2=[FCASH_CASE2(yy1) 0.7*FCASH_CASE2(yy2)];
    [xx3 yy3]=find(FCASHD_CASE2<0);
    [xx4 yy4]=find(FCASHD_CASE2>=0);
    FCASED2=[FCASHD_CASE2(yy3) 0.7*FCASHD_CASE2(yy4)];
    plot(0:n-1,FCASE2/1E6,':k+','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
    hold on;
    plot(0:n-1,FCASH_CASE1/1E6, 'LineStyle','-','LineWidth',3,'color',[1 0 0]);
    plot(0:n-1,FCASH_CASE2/1E6,'LineStyle',':','LineWidth',3,'color',[0 0 0]);
    plot(0:n-1,FCASED2/1E6,'-ko','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
    plot(0:n-1,FCASHD_CASE1/1E6,'LineStyle','-','LineWidth',3,'color',[0 0 1]);
    plot(0:n-1,FCASHD_CASE2/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
    hold off;
    % hold on;
    % plot(0:n-1,FCASH_BASE/1E6,'LineStyle','-','LineWidth',3,'color',[0 01 1]);
    % hold off
    xlim([0 n-1]);
    xlim([0 20]);
    set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
    ylabel(['Flujo de Caja Acumulativo' newline '(mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
    % ylim([-150 200]);
    xlabel('Año','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
    h=legend('Nominal, P_N_e_t_a menos ISR','Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_N_e_t_a menos ISR','Descuento, P_B_r_u_t_a','Descuento, P_N_e_t_a','Location','Northwest');
    %h.Font Size = 15;
    lgd.FontWeight = 'normal';
    %set(h,'LineStyle','-','LineWidth',2);
    grid
    %----------------------------------------------------------------------
    % Difference of Acumulative Cash Flow ($): with ISR
    %----------------------------------------------------------------------
    figure(np+3)
    DCASH1=REP1.DCASH;DCASH2=REP2.DCASH;
    DCASHD1=REP1.DCASHD;DCASHD2=REP2.DCASHD;
    [xx1 yy1]=find(DCASHD1<0);
    [xx2 yy2]=find(DCASHD1>=0);
    [xx3 yy3]=find(DCASHD2<0);
    [xx4 yy4]=find(DCASHD2>=0);
    DCASH=[DCASHD1(yy1) 0.7*DCASHD1(yy2)];
    DCASH1=[DCASHD2(yy3) 0.7*DCASHD2(yy4)];
    n=length(DCASHD1);
    % plot(0:n-1,DCASH/1E6, 'LineStyle','-','LineWidth',3,'color',[1 0 0]);
    plot(0:n-1,DCASH1/1E6,':k+','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
    % hold on;
    % plot(0:n-1,DCASH1/1E6,'LineStyle','--','LineWidth',3,'color',[0 0 0]);
    % hold off
    hold on;
    plot(0:n-1,DCASHD1/1E6, 'LineStyle','-','LineWidth',3,'color',[1 0 0]);
    %plot(0:n-1,DCASH/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
    plot(0:n-1,DCASH/1E6,'-ko','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1],'MarkerSize',10);
    plot(0:n-1,DCASHD2/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 1]);
    hold off
    % hold on;
    % plot(0:n-1,DCASHD1/1E6,'LineStyle','-.','LineWidth',3,'color',[0 0 0]);
    % hold off
    xlim([0 n-1]);
    set(gca,'fontname','tahoma','fontsize',18,'fontweight','light','LineWidth',2);
    ylabel(['Diferencia de Flujo Efectivo' newline ' Acumulativo (mmd)'],'fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal','rotation',90,...
    'HorizontalAlignment','center');
    % ylim([-150 200]);
    xlabel('Año','fontsize',18,'fontname','normal','FontAngle','normal','fontweight','normal',...
    'HorizontalAlignment','center');
    %h=legend('Nominal, P_B_r_u_t_a','Nominal, P_N_e_t_a','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a','Location','Northwest');
    h=legend('Descuento, P_B_r_u_t_a menos ISR','Descuento, P_B_r_u_t_a','Descuento con P_N_e_t_a menos ISR','Descuento con P_N_e_t_a','Location','Northwest');
    %h.Font Size = 15;
    lgd.FontWeight = 'normal';
    %set(h,'LineStyle','-','LineWidth',2);
    grid
    WT.plot=np+3;
end
