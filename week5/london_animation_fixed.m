clear all

outputDir = fullfile(getenv('HOME'),'UNI','MXB362','week5');
if ~exist(outputDir,'dir')
    mkdir(outputDir)
end

% Load underground station data
load Underground_station_data_MXB362 Station_data

% Initialise the figure
h = figure(1); clf

% Small sub-axis for total passengers
A2 = axes('position',[0.1 0.7 0.3 0.25],'color',0.3.*ones(1,3)); box on; hold on
xlim([0 24]); ylim([0 2]);
set(gca,'xtick',[0:2:24],'color',0.8.*ones(1,3))
xlabel('Hour','fontsize',19,'color',0.8.*ones(1,3))
ylabel('Trips (x 1000)','fontsize',19)

% Main axes
A1 = axes('position',[0.0 0.0 1 1]); hold on;

% Load road and water data
load London_road_water_data_MXB362 Rx* Ry* Thames_river

% Plot large and small roads
plot3(Rx1,Ry1,zeros(size(Rx1)),'color',0.4.*ones(1,3),'linewidth',1)
plot3(Rx2,Ry2,zeros(size(Rx2)),'color',0.4.*ones(1,3),'linewidth',3)

% Plot the Thames River
for i = 1:length(Thames_river)
    ptch = patch(Thames_river{i}(:,1),Thames_river{i}(:,2),'b');
    set(ptch,'edgecolor','none','linewidth',2,'facealpha',0.7,'BackFaceLighting','unlit');
end

set(gcf,'color',0.1.*ones(1,3))
set(gca,'color',0.1.*ones(1,3))
axis off

view([-13.5 30]);
zlim([0 5000]);
xlim([-0.5 0.33])
ylim([51.28 51.70])
[Xc,Yc,Zc] = cylinder(4e-3,4);

% Initialise the video file
if isunix && ~ismac
    aviFile = fullfile(outputDir,'LondonUnderground.avi');
    vidObj = VideoWriter(aviFile,'Motion JPEG AVI');
else
    mp4File = fullfile(outputDir,'LondonUnderground.mp4');
    vidObj = VideoWriter(mp4File,'MPEG-4');
end
vidObj.FrameRate = 10;
vidObj.Quality = 100;
open(vidObj);

axes(A1)
camlight

TotalPassengers = 0;

% Loop over all time-periods in the dataset
for t = 1:99

    axes(A1);
    for i = 1:size(Station_data,1)
        ss(i) = surf(Xc+Station_data{i,2},Yc+Station_data{i,3},Zc.*Station_data{i,t+3});
        set(ss(i),'edgecolor','none','facecolor',[1 0.6 0.6],'facealpha',1,'SpecularColorReflectance',0.5)
    end

    axes(A2);
    TotalPassengers = [TotalPassengers 1e-5.*sum([Station_data{:,t+3}])];
    plot(24.*[t-1 t]./100,[TotalPassengers(t) TotalPassengers(t+1)],'w','linewidth',2)

    currFrame = getframe(h);
    writeVideo(vidObj,currFrame);

    disp(t); delete(ss); clear ss
end

close(vidObj);

% MATLAB on Linux cannot write MPEG-4 directly, so convert the AVI with ffmpeg
if isunix && ~ismac
    mp4File = fullfile(outputDir,'LondonUnderground.mp4');
    command = sprintf('ffmpeg -y -loglevel error -i "%s" -c:v libx264 -pix_fmt yuv420p "%s"',aviFile,mp4File);
    status = system(command);
    if status ~= 0
        warning('AVI created, but ffmpeg could not create the MP4.')
    end
end
