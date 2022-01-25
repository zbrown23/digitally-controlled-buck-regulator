%% solving for Cin, Cout, RTon, and L, while minimizing output voltage ripple
% See the datasheet for Alpha and Omega Semiconductor AOZ2255LQI-31
% 
% The goal here is to minimize ripple current and voltage on the output over 
% a band of different setpoint voltages.
%% Equations
% $$T_{on} \propto V_{in} F_{sw}R_{Ton}$$
% 
% $$F_{sw}(kHz)=\frac{V_{out}}{V_{in}\times T_{on}(nS)}\times 10^6$$
% 
% $$\Delta I_{inductor}=\frac{V_{out}}{F_{sw}(Hz)\times L}\times \left(1-\frac{V_{out}}{V_{in}} 
% \right)$$
% 
% $\Delta V_{out} = \Delta I_{inductor} \times \left({ESR}_{C_{out}}+ \frac{1}{8\times 
% f \times C_{out} }\right)$x
% 
% $$P_{power\ loss} = \left(I_{out}{}+\frac{{\Delta I_{inductor}}}{2}\right) 
% ^2\times R_{inductor} \times 1.1$$
% 
% 
%% Create the Optimization Problem

clear
optimizationproblem = optimproblem("ObjectiveSense", "min");
%% Define Constant Parameters

Vin = 12.3;
Vout = 6.8;
Iout = 7;
ESRCout = 0.05;
Rinductor = 0.0045;
%% Setup Optimization Variables

RTon = optimvar('RTon');
Cout = optimvar('Cout');
L = optimvar('L');
%% Set Limits

RTon.LowerBound = 200000;
RTon.UpperBound = 800000;
Cout.LowerBound = 0;
Cout.UpperBound = 0.02;
L.LowerBound = 1e-7;
L.UpperBound = 10e-5;
%% Setup Equations

surface = getResistanceSurface('data.csv');
coeffs = coeffvalues(surface);
Ton = coeffs(1) + coeffs(2)*Vin + coeffs(3)*RTon + coeffs(4)*Vin*Vin + coeffs(5)*Vin*RTon + coeffs(6)*RTon*RTon; %RTon is in Kohm, Ton is in nS
Fsw = Vout/(Vin*Ton)*10e6; % Fsw is in kHz
Iinductor = Vout/(Fsw * 10e3 * L) * (1 - Vout/Vin);
optimizationproblem.Objective = Iinductor * (ESRCout + (1/(8 * Fsw * 10e3 * Cout)));
optimizationproblem.Constraints.Ton1 = (coeffs(1) + coeffs(2)*Vin + coeffs(3)*RTon + coeffs(4)*Vin*Vin + coeffs(5)*Vin*RTon + coeffs(6)*RTon*RTon) >= 100;
optimizationproblem.Constraints.Ton2 = (coeffs(1) + coeffs(2)*Vin + coeffs(3)*RTon + coeffs(4)*Vin*Vin + coeffs(5)*Vin*RTon + coeffs(6)*RTon*RTon) <= 800;
%% Initial Point

initialPoint.RTon = 10e2;
initialPoint.Cout = 0.01;
initialPoint.L = 6.8e-7;
%% Solve the Optimization Problem

solution = solve(optimizationproblem, initialPoint)
%% Calculate a surface for RTon, Ton, and Vin with data stored in a csv file

[surface, ImportedData] = getResistanceSurface('data.csv');
plot(surface);
xlabel("Input Voltage");
ylabel("Rton (kOhms)");
zlabel("On Time (ns)");
hold on
plot3(ImportedData(:,1), ImportedData(:,2), ImportedData(:,3), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
xlim([4,30])
ylim([100, 900])
zlim([0,1100])
hold off
%% Functions

function [surface, ImportedData] = getResistanceSurface(pathtoData)
ImportedData = table2array(readtable(pathtoData));
Vin = ImportedData(:,1);
RTon = ImportedData(:,2);
Ton = ImportedData(:,3);
surface = fit([Vin, RTon], Ton, 'poly22');
end