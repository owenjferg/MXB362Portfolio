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

vid = VideoWriter("LondonUnderground.mp4", "MPEG-4");
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


