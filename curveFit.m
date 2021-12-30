clear
ImportedData = table2array(readtable('data.csv'));
Vin = ImportedData(:,1);
RTon = ImportedData(:,2);
Ton = ImportedData(:,3);
surface = fit([RTon, Ton], Vin, 'poly22');
clf reset
plot(surface);
xlabel("RTon (kOhms)");
ylabel("Ton(ns)");
zlabel("Input Voltage (Volts)");
hold on
plot3(RTon, Ton, Vin, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
hold off