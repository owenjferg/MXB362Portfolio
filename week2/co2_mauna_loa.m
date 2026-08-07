load('ML_CO2_data.mat')
figure(1)
clf
hold on
box on
pp = plot(Data(:,3),Data(:,4))

get(pp)
set(pp,'linewidth',2,'color',[1 0 0])
set(pp,'linestyle',':')

xlabel('Year','fontsize',15)
ylabel('Atmospheric CO_2 concentration (ppm)','fontsize',15)
title('Atmospheric CO_2 concentration at Mauna Loa,','fontsize',16)
L = legend('Mauna Loa monthly averages');
set(L,'fontsize',14,'location','northwest')

xlim([1958 2020])
ylim([310 415])

% Second plot
subplot('position', [0.1 0.3 0.85 0.65])
hold on
box on
pp = plot(Data(:,3),Data(:,4));

xlabel('Year','fontsize',15)
ylabel('Atmospheric CO_2 concentration (ppm)','fontsize',15)
title('Atmospheric Carbon dioxide concentration at Mauna Loa, Hawai''i','fontsize',16)
L = legend('Mauna Loa monthly averages')
set(L,'fontsize',14,'location','northwest')
xlim([1958 2020])
ylim([310 415])

% export to tiff
set(gcf,'paperunits','centimeters','paperposition',[0 0 21 30])
print('-dtiff','-r300','Mauna_loa.tiff')