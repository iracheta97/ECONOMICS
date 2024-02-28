function [PB] = payback(CASH_FLOW)
% This function computes the Simple PAYBACK
% Date: June 5th, 2019
% Created by: Reynaldo Iracheta Cortez.

% Definitions:
% INPUTS:
% CASH_FLOW:    Cash Flows during N years of the project lifetime,

% OUTPUTS:
% PB:           Simple Payback or Discounted Payback (years)


% Project Period:
N=length(CASH_FLOW);            % Years
% Initialization:
P=0;
for i=1:N
    if CASH_FLOW(i)<0
        % Years of Payback:
        P=P+1;
    end
end

% Simple Payback:
if P==0
    PB=P;
elseif P==1
    % This code was adden in January 14th, 2023
    m=(CASH_FLOW(P));
    PB=1;
else
    % Interpolation for calculating the Simple Payback:
    %PB=CASH_FLOW(P-1)+0.5*(CASH_FLOW(P)+CASH_FLOW(P-1));
    % Slope:
    CASH_FLOW(P);
    CASH_FLOW(P-1);
    m=(CASH_FLOW(P)-CASH_FLOW(P-1));
    %PB=-CASH_FLOW(1)/m;
    %PB=CASH_FLOW(P-1)+0.5*(CASH_FLOW(P)+CASH_FLOW(P-1));
    PB=(P-1)-CASH_FLOW(P)/m;
end