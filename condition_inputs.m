function [PEL1, PEL2] = condition_inputs(P,PML,GDMTH,LOAD)

% This program condions inputs for its use in the economic model,
% POWER, EPR and LOAD profile per hour:

% Inputs:
% P:          Structure of power profile
% PML:        Precio Marginal Local (US$/kW),
% GDMTH:      GDMTH Rates (US$/kW),
% LOAD:       Load profile:
% LOAD1=LOAD.Data;        Load profile obtained from measurements (kW) which is compatible with PML and GDMTH,
% LOAD2=LOAD.GEN.PNET1;   Load profile obtained from POWER GENERATION profile (kW) which is compatible with PML and GMDTH

% Outputs:
% PEL1:       Power, Energy Load profile from PML for its use in the economic model,
% PEL2:       Power, Energy and Load profile from GMTDH rates.
% MPEL:       Power, Energy, Load Profile [GDMT PML].
%--------------------------------------------------------------------------
% Power profiles:
%--------------------------------------------------------------------------
P1=P.P1;
P2=P.P2;
P3=P.P3;
P4=P.P4;
%--------------------------------------------------------------------------
% Load profile:
%--------------------------------------------------------------------------
% Load1:
LOAD1=LOAD.Data;          % kW
% Load2:
LOAD2=LOAD.GEN.PNET1;     % kW
%--------------------------------------------------------------------------
% Conditioning inputs:
%--------------------------------------------------------------------------
% PML:
nyear=length(PML.Y);
nyear2=length(GDMTH.Y);
PEL1=[];PEL1.P1=[];PEL1.P2=[];PEL1.P3=[];PEL1.P4=[];
PEL1.nyear=nyear;           % Number of years
PEL1.Y=PML.Y;               % Year
% Counter:
for i=1:4
        count=0;
   for j=1:nyear
       % PML:
       EPR=eval(strcat('PML.','Y',num2str(PML.Y(j),'%.0f'),'.yy'));
       % GDMTH:
       [x1, y1]=find(GDMTH.Y==PML.Y(j));
       FF=isempty(y1);
       if FF==1
           EPRGM=EPR;
       else
           count=count+1;
           EPRGM=eval(strcat('GDMTH.','Y',num2str(GDMTH.Y(y1),'%.0f'),'.PR'));
       end
       % Power:
       P=eval(strcat('P',num2str(i,'%.0f')));
       % Power, Energy prices and Load profiles:
       [pel] = power_hour(P,EPRGM, EPR,LOAD);
       % Adding the year to pel structure:
       pel.yy=PML.Y(j);
       % Adding PML:
       pel.ERATE1='GDMTH';
       pel.ERATE2='PML';
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
       eval([m2 '=PEL1;'])
   end
end
% Electricity rate:(USD/kW)
PEL1.ERATE=PML.ERATE;           % USD/kWh
%PEL1.ERATE2=PML.ERATE;             % USD/kWh
% Exchange rate (USD/MXN):
PEL1.TC=PML.TC;
%--------------------------------------------------------------------------
% GDMTH:
%--------------------------------------------------------------------------
nyear=length(GDMTH.Y);
nyear2=length(PML.Y);
PEL2=[];PEL2.P1=[];PEL2.P2=[];PEL2.P3=[];PEL2.P4=[];
PEL2.nyear=nyear;           % Number of years
PEL2.Y=GDMTH.Y;             % Year
for i=1:4
    count=0;
   for j=1:nyear
       % PML:
       EPRGM=eval(strcat('GDMTH.','Y',num2str(GDMTH.Y(j),'%.0f'),'.PR'));
       % GDMTH:
       [x2, y2]=find(PML.Y==GDMTH.Y(j));
       FF2=isempty(y2);
       if FF==1
           EPR=EPRGM;
       else
           count=count+1;
           EPR=eval(strcat('PML.','Y',num2str(PML.Y(y2),'%.0f'),'.yy'));
       end
       % Power:
       P=eval(strcat('P',num2str(i,'%.0f')));
       % Power, Energy prices and Load profiles:
       [pel] = power_hour(P,EPRGM,EPR,LOAD);
       % Adding the year to pel structure:
       pel.yy=GDMTH.Y(j);
       % Adding GMDTH:
       pel.ERATE1='GDMTH';
       pel.ERATE2='PML';
       m1=strcat('PEL2',num2str(i,'%.0f'),'_',num2str(GDMTH.Y(j),'%.0f'));
       m2=strcat('PEL2',num2str(i,'%.0f'));
       yy=strcat('Y',num2str(GDMTH.Y(j),'%.0f'));
       eval([m2 '=m2;'])
       %PEL2= setfield(PEL2,yy,pel);                         % Power profile
       if i==1
        PEL2.P1= setfield(PEL2.P1,yy,pel);                   % Power profile 
        %PEL2.P1.yy= setfield(PEL2.P1.yy,year,GMDTH.Y(j));    % Power profile  
       end
       if i==2
        PEL2.P2= setfield(PEL2.P2,yy,pel);                    % Power profile 
        %PEL2.P2.yy= setfield(PEL2.P1.yy,year,GMDTH.Y(j));     % Power profile  
       end
       if i==3
        PEL2.P3= setfield(PEL2.P3,yy,pel);                     % Power profile  
        %PEL2.P3.yy= setfield(PEL2.P1.yy,year,GMDTH.Y(j));     % Power profile  
       end
       if i==4
        PEL2.P4= setfield(PEL2.P4,yy,pel);                     % Power profile
        %PEL2.P4.yy= setfield(PEL2.P1.yy,year,GMDTH.Y(j));     % Power profile  
       end
   end
       eval([m2 '=PEL2;'])
end
% Electricity rate:(USD/kW)
PEL2.ERATE=GDMTH.ERATE;             % USD/kWh
%PEL2.ERATE2=PML.ERATE;             % USD/kWh
% Exchange rate (USD/MXN):
PEL2.TC=GDMTH;
