%% London underground

clear
close all

GRAY10 = [0.1 0.1 0.1];
GRAY40 = [0.4 0.4 0.4];
GRAY80 = [0.8 0.8 0.8];

fig = figure;

smallAx = axes(fig, Position=[0.1 0.7 0.3 0.25], Color=[0.3 0.3 0.3]);
box on
hold on
xlim([0 24])
ylim([0 2])
set(smallAx, xtick=0:2:24, color=GRAY80)
xlabel(smallAx, "Hour", FontSize=12, Color=GRAY80)
ylabel(smallAx, "Trips", FontSize=12, Color=GRAY80)

ax = axes(fig, Position=[0 0 1 1]); hold on;

load London_road_water_data_MXB362.mat Rx* Ry* Thames_river

plot3(ax, Rx1, Ry1, 0*Rx1, Color=GRAY40, LineWidth=1) % small roads
plot3(ax, Rx2, Ry2, 0*Rx2, Color=GRAY40, LineWidth=3) % large roads

cellfun(@(part) ...
    patch(ax, part(:,1), part(:,2), "b", ...
        EdgeColor="none", LineWidth=2, FaceAlpha=0.7, BackFaceLighting="unlit"), ...
    Thames_river ...
);

set(ax, Color=GRAY10)
set(fig, Color=GRAY10)
axis off

view([-13.5, 30])
zlim([0 5000])
xlim([-0.5 0.33])
ylim([51.28 51.70])
[Xc,Yc,Zc] = cylinder(4e-3, 4);

camlight

vid = VideoWriter("LondonUnderground.mp4", "Motion JPEG AVI");
vid.FrameRate = 10;
vid.Quality = 100;
open(vid);

load Underground_station_data_MXB362.mat Station_data

% Pre allocating the station columns
surfs = {};
for i = 1:height(Station_data)
    surfs{i} = surf(ax, Xc+Station_data{i,2}, Yc+Station_data{i,3}, Zc .* Station_data{i,4}, ...
        EdgeColor="none", FaceColor=[1 0.6 0.6], FaceAlpha=1.0, SpecularColorReflectance=0.5);
end

TotalPassengers = [0];
for t = 1:96

    for i = 1:height(Station_data)
        surfs{i}.ZData = Zc .* Station_data{i,t+3};
    end

    TotalPassengers = [TotalPassengers 1e-5 .* sum([Station_data{:,t+3}])];
    plot(smallAx, 24 .* [t-1 t]./100, [TotalPassengers(t), TotalPassengers(t+1)], "w", LineWidth=2)

    frame = getframe(fig);
    writeVideo(vid, frame);

end

close(vid)


%% Pendulum

DE2 = @(x,t,g,L) [x(2); -g/L * sin(x(1))];

L0 = 1; % length of first pendulum
n = 16; % num pendulums
R = 51; % decay rate of pendulum length
g = 9.81; % gravity

IC = [pi/6, 0]; % initial angle and time

for i = 1:n

    L = L0 * (R/(R+i-1)).^2;

    [t,x] = ode45(@(t,x) DE2(x,t,g,L), 0:0.05:120, IC);

    angles = x(:,1);

    Y(:,i) = -L .* cos(angles);
    X(:,i) = L .* sin(angles);

end

h = figure; hold on;
view([-90 -5]); camlight; axis off vis3d
xlim([0 1.2]); ylim([-1.1 1.1]); zlim([-1.1 0]);

% background
patch([1.1 1.1 1.1 1.1], [-1 1 1 -1], [0 0 -1 -1], [0.5 0.5 0.5]);

% colormap
CL = parula(n);
CL = flip(CL, 1);

% preallocate graphics objects
lines = {};
markers = {};
for t = 1:1
    for i = 1:n
        lines{i} = plot3([i i]./n, [0 X(t,i)], [0 Y(t,i)], "-", Color=[0.8 0.8 0.8], MarkerSize=20);
        markers{i} = plot3(i./n, X(t,i), Y(t,i), ".", Color=CL(i,:), MarkerSize=20);
    end
end

% update only Y data and Z data then write to gif
for t = 1:height(X)
    for i = 1:n
        lines{i}.YData = [0 X(t,i)];
        lines{i}.ZData = [0 Y(t,i)];
        markers{i}.YData = X(t,i);
        markers{i}.ZData = Y(t,i);
    end

    [imind, cm] = rgb2ind(frame2im(getframe(h)), 256);
    imwrite(imind, cm, "Pendulum.gif", WriteMode="append", DelayTime=0.02);
end
