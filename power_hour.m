function [P1] = power_hour(P,EPR,EPRGM,LOAD)
%function [PGROSS1,PNET1,PWAKE1,PLOSS1,EPR1, LOAD1] = power_hour(P,EPR,LOAD)
% This program re-calculate POWER, EPR and LOAD profile per hour:
% Inputs:
% P:          Power profile structure
% P.GROSS:    Gross power,
% P.NET:      Net power,
% P.WAKE:     Wake power,
% P.LOSS:     Loss power,
% EPR:        Energy price to buy energy,
% EPRGM:      Energy price to sell energy,
% LOAD:       Load structure.
% LOAD1=LOAD.Data;        Load profile obtained from measurements (kW) which is compatible with PML and GDMTH,
% LOAD2=LOAD.GEN.PNET1;   Load profile obtained from POWER GENERATION profile (kW) which is compatible with PML and GMDTH

% Outputs:
% PGROSS1:    Gross power,
% PNET1:      Net power,
% PWAKE1:     Wake power,
% PLOSS1:     Loss power,
% EPR1:       Energy price,
% LOAD1:      Load profile,
% LOAD2:      Annual load profile.
%--------------------------------------------------------------------------
% Extract values:
%--------------------------------------------------------------------------
PGROSS=P.GROSS;
PNET=P.NET;
PWAKE=P.WAKE;
PLOSS=P.LOSS;
UNITS=P.UNITS;              % kW
%--------------------------------------------------------------------------
% Units:
% MW=1; kW=2; W=3
%--------------------------------------------------------------------------
if UNITS=='MW'
    F=1e3;
elseif UNITS=='kW'
    F=1;
else
    F=1/1000;
end
%--------------------------------------------------------------------------
% Load Units:
%--------------------------------------------------------------------------
% Load1:
LOADL=LOAD.Data;                % kW
% Load2:
LOADG=LOAD.GEN.PNET1;           % kW
UNITSL=LOAD.UNITS;              % kW
if UNITSL=='MW'
    FL=1e3;
elseif UNITSL=='kW'
    FL=1;
else
    FL=1/1000;
end
%--------------------------------------------------------------------------
% Clasification:
%--------------------------------------------------------------------------
x1=length(PGROSS);
x2=length(PNET);
x3=length(PWAKE);
x4=length(PLOSS);
x5=length(EPR);
x6=length(LOADL);
x7=length(LOADG);
x8=length(EPRGM);
% Hour per year:
hy=8760;              % Hours
% Ten-minute per year:
dmy=hy*6;             % Ten-minute
%--------------------------------------------------------------------------
% Power:
%--------------------------------------------------------------------------
if x1<=8784 & x1>500  % Hour samples
    PGROSS1=F*PGROSS;
    PNET1=F*PNET;
    PWAKE1=F*PWAKE;
    PLOSS1=F*PLOSS;
elseif x1<=500        % Day samples
    N=length(PGROSS);
    for i=1:N
    ii=24*(i-1)+1;
    PGROSS1(ii:24*i,1)=F*mean(P.GROSS(i));
    PNET1(ii:24*i,1)=F*mean(P.NET(i));              % kWh Net Energy Production,
    PWAKE1(ii:24*i,1)=F*mean(P.WAKE(i));            % Energy Loss due to Wake Effect,
    PLOSS1(ii:24*i,1)=F*mean(P.LOSS(i));            % Energy Loss due to Joule Losses in Cables.
    end
else %x1>=52560      % Ten-minute samples
    N=round(length(PGROSS)/6)-1;
    for i=1:N
        ii=6*(i-1)+1;
    if i>N
        break;
    end
    PGROSS1(i,1)=F*mean(P.GROSS(ii:6*i));
    PNET1(i,1)=F*mean(P.NET(ii:6*i));              % kWh Net Energy Production,
    PWAKE1(i,1)=F*mean(P.WAKE(ii:6*i));            % Energy Loss due to Wake Effect,
    PLOSS1(i,1)=F*mean(P.LOSS(ii:6*i));            % Energy Loss due to Joule Losses in Cables.
    end
end
%--------------------------------------------------------------------------
% Energy prices: (To buy energy)
%--------------------------------------------------------------------------
if x5<=8784 & x5>500  % Hour samples
    EPR1=EPR;
elseif x5<=500        % Day samples
    N=length(EPR);
    for i=1:N
    ii=24*(i-1)+1;
    EPR1(ii:24*i,1)=mean(EPR(i));                 % USD/kW Energy prices.
    end
else %x1>=52560      % Ten-minute samples
    N=round(length(EPR)/6)-1;
    for i=1:N
        ii=6*(i-1)+1;
    if i>N
        break;
    end
    EPR1(i,1)=mean(EPR(ii:6*i));
    end
end
%--------------------------------------------------------------------------
% Energy prices: (To sell energy)
%--------------------------------------------------------------------------
if x8<=8784 & x8>500  % Hour samples
    EPR2=EPRGM;
elseif x8<=500        % Day samples
    N=length(EPRGM);
    for i=1:N
    ii=24*(i-1)+1;
    EPR2(ii:24*i,1)=mean(EPRGM(i));                 % USD/kW Energy prices.
    end
else %x1>=52560      % Ten-minute samples
    N=round(length(EPRGM)/6)-1;
    for i=1:N
        ii=6*(i-1)+1;
    if i>N
        break;
    end
    EPR2(i,1)=mean(EPRGM(ii:6*i));
    end
end
%--------------------------------------------------------------------------
% Load profile 1:
%--------------------------------------------------------------------------
if x6<=8784 & x6>500  % Hour samples
    LOAD1=FL*LOADL;
elseif x6<=500        % Day samples
    N=length(LOADL);
    for i=1:N
    ii=24*(i-1)+1;
    LOAD1(ii:24*i,1)=FL*mean(LOADL(i));                 % USD/kW Energy prices.
    end
else %x1>=52560      % Ten-minute samples
    N=round(length(LOADL)/6)-1;
    for i=1:N
        ii=6*(i-1)+1;
    if i>N
        break;
    end
    LOAD1(i,1)=FL*mean(LOADL(ii:6*i));
    end
end
%--------------------------------------------------------------------------
% Load profile 2:
%--------------------------------------------------------------------------
if x7<=8784 & x7>500  % Hour samples
    LOAD2=FL*LOADG;
elseif x7<=500        % Day samples
    N=length(LOADG);
    for i=1:N
    ii=24*(i-1)+1;
    LOAD2(ii:24*i,1)=FL*mean(LOADG(i));                 % USD/kW Energy prices.
    end
else %x1>=52560      % Ten-minute samples
    N=round(length(LOADG)/6)-1;
    for i=1:N
        ii=6*(i-1)+1;
    if i>N
        break;
    end
    LOAD2(i,1)=FL*mean(LOADG(ii:6*i));
    end
end
%--------------------------------------------------------------------------
% OUTPUT:
%--------------------------------------------------------------------------
P1=[];
P1= setfield(P1,'WBASE',P.WBASE);                   % Wind DATABASE
P1= setfield(P1,'WT',P.WT);                         % Wind turbine type
P1= setfield(P1,'GROSS',PGROSS1');                  % Gross Output Power (kW)
P1= setfield(P1,'NET',PNET1');                      % Net Output Power (kW)
P1= setfield(P1,'WAKE',PWAKE1');                    % Wake Loss (kW)
P1= setfield(P1,'LOSS',PLOSS1');                    % Joule Loss (kW)
P1= setfield(P1,'EPR1',EPR1(:,1)');                 % Joule Loss (kW)
P1= setfield(P1,'EPR2',EPR2(:,1)');                 % Joule Loss (kW)
P1= setfield(P1,'LOAD1',LOAD1');                    % Load1 (kW)
P1= setfield(P1,'LOAD2',LOAD2');                    % Load2 (kW)
P1= setfield(P1,'UNTS',P.UNITS);                    % Power units

