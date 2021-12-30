clear
Vin = 12;
Vout = 8.5;
ESRCout = 0.05;
L = linspace(0,0.01,10)';
RTon = linspace(0,800000,10)';
Cout = linspace(0,0.02,10)';

[surface, ~] = getResistanceSurface('data.csv');
coeffs = coeffvalues(surface);

Vripple = zeros(size(RTon, 1),size(Cout, 1),size(L, 1));
for i = 1:size(RTon)
    for j = 1:size(Cout)
        for k = 1:size(L)
            Ton(i) = coeffs(1) + coeffs(2)*Vin + coeffs(3)*RTon(i) + coeffs(4)*Vin*Vin + coeffs(5)*Vin*RTon(i) + coeffs(6)*RTon(i)*RTon(i); %RTon is in Kohm, Ton is in nS
            Fsw = (Vout/(Vin*Ton(i)))*10e6; % Fsw is in kHz
            Iinductor = Vout/(Fsw * 10e3 * L(k)) * (1 - Vout/Vin);
            Vripple(i,j,k) = Iinductor * (ESRCout + (1/(8 * Fsw * 10e3 * Cout(j))));
        end
    end
end


%{
clear
[surface, ~] = getResistanceSurface('data.csv');
coeffs = coeffvalues(surface);
Vin = 12;
Vout = 8.5;
ESRCout = 0.05;
L = 6.8e-7;
RTon = 50;
Cout = 50;
Ton = coeffs(1) + coeffs(2)*Vin + coeffs(3)*RTon + coeffs(4)*Vin*Vin + coeffs(5)*Vin*RTon + coeffs(6)*RTon*RTon; %RTon is in Kohm, Ton is in nS
Fsw = (Vout/(Vin*Ton))*10e6; % Fsw is in kHz
Iinductor = Vout/(Fsw * L) * (1 - Vout/Vin);
Vripple = Iinductor * (ESRCout + (1/(8 * Fsw * Cout)))
%}

function [surface, ImportedData] = getResistanceSurface(pathtoData)
    ImportedData = table2array(readtable(pathtoData));
    Vin = ImportedData(:,1);
    RTon = ImportedData(:,2);
    Ton = ImportedData(:,3);
    surface = fit([Vin, RTon], Ton, 'poly22');
end