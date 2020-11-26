%% initialize Pmtk3
initPmtk3

%% Load Data
readtable('codon_usage.csv')

%% Prep Data
close all;
xValues = table2array(codonusage(:,6:end));
yValues = table2array(codonusage(:,1));
Labels = table2array(codonusage(:,5));

%Checkout initial data
figure
for i=1:width(xValues)
   subplot(8,8,i)
   plot(xValues(:,i))
   set(gca,'xtick',[])
   set(gca,'ytick',[])
end

%Split xValues and yValues in Train and Test sets to a deffined percentage
perc = 0.5;

