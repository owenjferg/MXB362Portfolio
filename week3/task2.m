clear all

r = 2.2;
N = 0.3;

figure(1), clf

subplot(3,1,1), box on

for t = 1:99
    N(t+1) = r*N(t)*(1 - N(t));
end

plot([1:100],N,'linewidth',2)
xlim([1 100]); ylim([0 1.1])
title(['Growth rate  = ' num2str(r,3)])

%for different values of r

r = 3.2;
subplot(3,1,2), box on
for t = 1:100
    N(t+1) = r*N(t)*(1 - N(t));
end
plot(N,'linewidth',2)
xlim([1 100]); ylim([0 1.1])
title(['Growth Rate = ' num2str(r,3)])

%repeat with another different r

r = 4;
subplot(3,1,3), box on
for t = 1:100
    N(t+1) = r*N(t)*(1 - N(t));
end
plot(N,'linewidth',2)
xlim([1 100]); ylim([0 1.1])
title(['Growth Rate = ' num2str(r,3)])

% Initialise new figure
figure(2), clf, hold on, box on;

r_list = linspace(2.5,3.8,1500);

XX = []; YY = [];

%go through r values in for loop
for i = 1:length(r_list)
    N = 0.3;
    r = r_list(i);
    
    %simulate population
    for t = 1:1000
        N(t+1) = r*N(t)*(1 - N(t));
    end

    %save 200 values in time series
    Y = N(800:end);

    X = ones(size(Y))*r;

    XX = [XX X]; YY = [YY Y];
end

plot(XX, YY, '.', 'MarkerSize', 1, 'Color', 'b');
xlabel('r (Growth Rate Value)');
ylabel('Attractor Set');
title('Bifurcation Diagram');
