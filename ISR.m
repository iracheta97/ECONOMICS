function [x,TAX,TAXSUM]=ISR(FCASH_CASE2,TC)
% FUNCIÓN PARA CARCULAR EL ISR 2023 (ANUAL)
% TC es la tasa de cambio de peso a dólar
% FCASH es el flujo de caja en dólares
% FCASHP es el flujo de caja en pesos
% IMPUESTO en pesos
% PE es la percepción económica después de los impuestos en pesos
% TAX impuesto a retener en dólares 
% x percepción económica en dólares 

ISR1=xlsread('LISR_MAT.xlsx');
FCASHP=FCASH_CASE2*TC;
%INGRESO = FCASHP; % Ingresar el valor de ingresos anuales en MXN

if length(FCASHP)==1
    FC=FCASHP;
else
    [Px Py]=find(FCASHP>0);
    [Pxx Pyy]=find(FCASHP<=0);
    if length(Py)==0
      %RESTA=FCASHP(Py(2:end))-FCASHP(Py(1:end-1));
      FC=[0*FCASHP(Pyy)];
    elseif length(Pyy)==0
      RESTA=FCASHP(Py(2:end))-FCASHP(Py(1:end-1));
      FC=[FCASHP(Py(1)) RESTA];
    else
      RESTA=FCASHP(Py(2:end))-FCASHP(Py(1:end-1));
      FC=[0*FCASHP(Pyy) FCASHP(Py(1)) RESTA];
    end
end
INGRESO=FC;
count=0;
for j = 1:length(INGRESO)
    count=count+1;
    if INGRESO(j) >= ISR1(end,1)
        IMPUESTO(j) = ((INGRESO(j) - ISR1(end,1))*((ISR1(end,4)/100)) + ISR1(end,3));
        PE(j) = INGRESO(j) - IMPUESTO(j);
    else 
        for i = 1:size(ISR1,1)-1
%             P=find(FCASH_CASE2>=0);
% diferencia = diff(P);
% INGRESO=diferencia;
                IMPUESTO(j) = 0;
                PE(j) = 0;
            if INGRESO(j) >= ISR1(i,1) && INGRESO(j) <= ISR1(i,2)
                IMPUESTO(j) = (INGRESO(j) - ISR1(i,1))*((ISR1(i,4)/100)) + ISR1(i,3);    % Impuestos a retener
                PE(j) = INGRESO(j) - IMPUESTO(j);      % Percepción efectiva
                break;
            elseif INGRESO(j) < ISR1(1,1)
                IMPUESTO(j) = 0;
                PE(j) = 0;
            end
        end
    end
end
TAX=IMPUESTO/TC;
x=PE/TC;
TAXSUM=cumsum(TAX);



% function [x,TAX]=ISR(FCASH_CASE2,TC)
% % FUNCIÓN PARA CALCULAR EL ISR 2023 (ANUAL)
% % FCASH_CASE2 es el flujo de caja en dólares
% % TC es la tasa de cambio de peso a dólar
% % x es la percepción económica en dólares 
% % TAX es el impuesto a retener en dólares 
% 
% % Leer datos de la tabla de impuestos
% ISR1=xlsread('LISR_MAT.xlsx');
% 
% % Convertir el flujo de caja a pesos mexicanos
% FCASHP=FCASH_CASE2*TC;
% INGRESO = FCASHP; % Ingresar el valor de ingresos anuales en MXN
% 
% % Implementar la lógica para restar valores mayores a cero
% [Px Py]=find(FCASH_CASE2>0);
% [Pxx Pyy]=find(FCASH_CASE2=<0);
% RESTA=FCASH_CASE2(Py(2:end))-FCASH_CASE2(Py(1:end-1));
% FC=[0*FCASH_CASE2(Pyy) FCASH_CASE2(Py(1)) RESTA]
% diferencia = diff(P);
% INGRESO1=FCASH_CASE2(diferencia>0);
% 
% % Calcular impuestos y percepción económica para cada ingreso
% for j = 1:length(INGRESO)
%     % Si el ingreso es mayor al último rango de impuestos
%     if INGRESO(j) >= ISR1(end,1)
%         IMPUESTO(j) = ((INGRESO(j) - ISR1(end,1))*((ISR1(end,4)/100)) + ISR1(end,3));
%         PE(j) = INGRESO(j) - IMPUESTO(j);
%     else 
%         % Si el ingreso está dentro de un rango de impuestos
%         for i = 1:size(INGRESO,1)
%             if INGRESO(j) >= ISR1(i,1) && INGRESO(j) <= ISR1(i,2)
%                 % Calcular impuestos a retener
%                 if i == 1 % Primer rango
%                     IMPUESTO(j) = (INGRESO(j) - ISR1(i,1))*((ISR1(i,4)/100)) + ISR1(i,3);
%                 else % Siguientes rangos
%                     IMPUESTO_ACUM = sum((INGRESO1(1:i-1) - ISR1(1:i-1,1)).*(ISR1(1:i-1,4)/100) + ISR1(1:i-1,3));
%                     IMPUESTO(j) = (INGRESO(j) - INGRESO1(i-1))*((ISR1(i,4)/100)) + ISR1(i,3) - IMPUESTO_ACUM;
%                 end
%                 PE(j) = INGRESO(j) - IMPUESTO(j); % Percepción efectiva
%                 break;
%             elseif INGRESO(j) <= ISR1(1,1)
%                 IMPUESTO(j) = 0;
%                 PE(j) = 0;
%             end
%         end
%     end
% end
% 
% 
