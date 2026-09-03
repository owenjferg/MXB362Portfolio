clear;
clc;
close all;


%% ============================================================
%  LOAD DATA
%  ============================================================

load('London_road_water_data_MXB362.mat', ...
    'Rx1','Ry1','Rx2','Ry2','Thames_river');

load('Underground_station_data_MXB362.mat', ...
    'Station_data');


%% ============================================================
%  EXTRACT STATION DATA
%  ============================================================

% Column 1 = station name
stationNames = Station_data(:,1);

% Column 2 = longitude
stationLon = cell2mat(Station_data(:,2));

% Column 3 = latitude
stationLat = cell2mat(Station_data(:,3));

% Columns 4:end = trip numbers
trips = cell2mat(Station_data(:,4:end));

% Replace any missing values with zero
trips(isnan(trips)) = 0;

nStations = size(trips,1);
nTimes = size(trips,2);

maxTrips = max(trips(:));

if maxTrips == 0 || ~isfinite(maxTrips)
    maxTrips = 1;
end

% Total passengers at each time period
totalTrips = sum(trips,1);

% Dataset covers 24 hours
hours = (0:nTimes-1) * (24/nTimes);


%% ============================================================
%  CONVERT LONGITUDE / LATITUDE INTO LOCAL X/Y COORDINATES
%  ============================================================

lat0 = mean(stationLat);
lon0 = mean(stationLon);

[xs0, ys0] = geoToXY( ...
    stationLon, ...
    stationLat, ...
    lat0, ...
    lon0, ...
    1);

extent = max([ ...
    myRange(xs0), ...
    myRange(ys0)]);

if extent == 0 || ~isfinite(extent)

    scale = 1;

else

    % Scale London so that the map has convenient dimensions
    scale = 120 / extent;

end

xs = xs0 * scale;
ys = ys0 * scale;


%% ============================================================
%  CREATE FIGURE
%  ============================================================

fig = figure( ...
    'Name','London Underground Population Animation', ...
    'Color','w', ...
    'Position',[100 100 1200 800]);

axMap = axes( ...
    'Parent',fig, ...
    'Position',[0.05 0.08 0.78 0.84]);

hold(axMap,'on');
box(axMap,'on');
grid(axMap,'on');

axis(axMap,'equal');

view(axMap,3);


%% ============================================================
%  PLOT LONDON ROADS
%  ============================================================

% Smaller roads
plotGeoLines( ...
    Rx1, ...
    Ry1, ...
    lat0, ...
    lon0, ...
    scale, ...
    axMap, ...
    [0.30 0.30 0.30], ...
    0.7);

% Larger roads
plotGeoLines( ...
    Rx2, ...
    Ry2, ...
    lat0, ...
    lon0, ...
    scale, ...
    axMap, ...
    [0.60 0.60 0.60], ...
    0.35);


%% ============================================================
%  PLOT THE THAMES
%  ============================================================

patchThames( ...
    Thames_river, ...
    lat0, ...
    lon0, ...
    scale, ...
    axMap, ...
    [0.15 0.45 0.75]);


%% ============================================================
%  SET MAP BOUNDS
%  ============================================================

dx = myRange(xs);
dy = myRange(ys);

if dx == 0
    dx = 1;
end

if dy == 0
    dy = 1;
end

pad = 0.08 * max([dx dy]);

% Maximum height of station bars
zmax = 0.25 * max([dx dy]);

xlim(axMap, ...
    [min(xs)-pad, ...
     max(xs)+pad]);

ylim(axMap, ...
    [min(ys)-pad, ...
     max(ys)+pad]);

zlim(axMap, ...
    [0 zmax]);

xlabel(axMap,'X');
ylabel(axMap,'Y');
zlabel(axMap,'Trips');


%% ============================================================
%  CREATE BASIC RECTANGULAR PRISM
%  ============================================================

% cylinder(...,4) creates a four-sided prism
[px, py, pz] = cylinder(1,4);

% Rotate the square slightly
th = pi/4;

pxr = px*cos(th) - py*sin(th);
pyr = px*sin(th) + py*cos(th);

% Width of each station bar
barWidth = 0.005 * max([dx dy]);


%% ============================================================
%  COLOUR SETTINGS
%  ============================================================

colormap(axMap, parula);

caxis(axMap, [0 maxTrips]);

cb = colorbar(axMap);

ylabel(cb,'Trips');


%% ============================================================
%  CREATE TOTAL TRAVELLER GRAPH
%  ============================================================

axTotal = axes( ...
    'Parent',fig, ...
    'Position',[0.67 0.70 0.25 0.18]);

plot( ...
    axTotal, ...
    hours, ...
    totalTrips, ...
    'k', ...
    'LineWidth',1.2);

hold(axTotal,'on');

hNow = plot( ...
    axTotal, ...
    hours(1), ...
    totalTrips(1), ...
    'ro', ...
    'MarkerFaceColor','r', ...
    'MarkerSize',7);

xlim(axTotal,[0 24]);

xlabel(axTotal,'Time (hours)');
ylabel(axTotal,'Total trips');

title(axTotal,'Total Underground Trips');

grid(axTotal,'on');


%% ============================================================
%  OUTPUT LOCATION
%  ============================================================

% This corresponds to:
%
% ~/UNI/MXB362/week5

outputDir = fullfile( ...
    getenv('HOME'), ...
    'UNI', ...
    'MXB362', ...
    'week5');

% Create the folder if it does not exist
if ~exist(outputDir,'dir')

    mkdir(outputDir);

end


%% ============================================================
%  SET UP AVI VIDEO
%  ============================================================
%
% MATLAB on Linux does not normally support:
%
% VideoWriter(...,'MPEG-4')
%
% Therefore we first create an AVI and convert it to MP4 using ffmpeg.

aviFile = fullfile( ...
    outputDir, ...
    'London_population_animation.avi');

mp4File = fullfile( ...
    outputDir, ...
    'London_population_animation.mp4');


fprintf('\n');
fprintf('============================================\n');
fprintf('Creating London animation\n');
fprintf('============================================\n');
fprintf('Temporary AVI:\n%s\n\n', aviFile);


% Delete an old AVI if one exists
if exist(aviFile,'file')

    delete(aviFile);

end


% Delete an old MP4 if one exists
if exist(mp4File,'file')

    delete(mp4File);

end


% Motion JPEG AVI works on Linux
v = VideoWriter( ...
    aviFile, ...
    'Motion JPEG AVI');

v.FrameRate = 8;
v.Quality = 100;

open(v);


%% ============================================================
%  CREATE ANIMATION
%  ============================================================

for k = 1:nTimes

    % Make sure new surfaces are drawn on the map
    axes(axMap);

    % Store handles so that the bars can be deleted after each frame
    hs = gobjects(0);


    %% --------------------------------------------------------
    %  DRAW EVERY STATION
    %  ---------------------------------------------------------

    for i = 1:nStations

        tripValue = trips(i,k);

        % Convert trip count to visual bar height
        hgt = tripValue / maxTrips * zmax;


        % Ignore stations with zero / invalid data
        if hgt <= 0 || ~isfinite(hgt)

            continue;

        end


        % Shift the prism to the station location
        X = xs(i) + barWidth * pxr;
        Y = ys(i) + barWidth * pyr;

        % Stretch prism according to passenger count
        Z = hgt * pz;

        % Use trip number for colour
        C = tripValue * ones(size(Z));


        % Draw station prism
        hs(end+1) = surf( ...
            axMap, ...
            X, ...
            Y, ...
            Z, ...
            C, ...
            'EdgeColor','none', ...
            'FaceColor','flat');

    end


    %% --------------------------------------------------------
    %  UPDATE TOTAL PASSENGER GRAPH
    %  ---------------------------------------------------------

    set( ...
        hNow, ...
        'XData',hours(k), ...
        'YData',totalTrips(k));


    %% --------------------------------------------------------
    %  CREATE TIME LABEL
    %  ---------------------------------------------------------

    currentHour = floor(hours(k));

    currentMinute = round( ...
        (hours(k) - currentHour) * 60);


    % Correct any rounding to 60 minutes
    if currentMinute == 60

        currentMinute = 0;
        currentHour = currentHour + 1;

    end


    title( ...
        axMap, ...
        sprintf( ...
            'London Underground Trips - %02d:%02d', ...
            currentHour, ...
            currentMinute));


    %% --------------------------------------------------------
    %  DRAW FRAME
    %  ---------------------------------------------------------

    drawnow;


    %% --------------------------------------------------------
    %  WRITE FRAME TO VIDEO
    %  ---------------------------------------------------------

    frame = getframe(fig);

    writeVideo(v,frame);


    %% --------------------------------------------------------
    %  DELETE STATION BARS
    %  ---------------------------------------------------------

    delete(hs);


    %% --------------------------------------------------------
    %  SHOW PROGRESS
    %  ---------------------------------------------------------

    fprintf( ...
        'Frame %d of %d complete\n', ...
        k, ...
        nTimes);

end


%% ============================================================
%  CLOSE AVI
%  ============================================================

close(v);

fprintf('\nAVI created successfully:\n');
fprintf('%s\n',aviFile);


%% ============================================================
%  CONVERT AVI TO MP4 USING FFMPEG
%  ============================================================

fprintf('\nConverting AVI to MPEG-4...\n');


% Check whether ffmpeg is installed
[ffmpegStatus,~] = system('ffmpeg -version > /dev/null 2>&1');


if ffmpegStatus ~= 0

    fprintf('\n');
    fprintf('============================================\n');
    fprintf('FFMPEG NOT FOUND\n');
    fprintf('============================================\n');

    fprintf([ ...
        'The AVI was created successfully, but ffmpeg is not installed.\n\n' ...
        'Install it from a terminal using:\n\n' ...
        'sudo apt update\n' ...
        'sudo apt install ffmpeg\n\n' ...
        'Then run this MATLAB script again.\n\n']);

else

    % -y overwrites an existing MP4
    %
    % libx264 produces H.264 MPEG-4 video
    %
    % yuv420p improves compatibility with browsers,
    % Windows, macOS and portfolio upload systems.

    ffmpegCommand = sprintf( ...
        ['ffmpeg -y -loglevel error ' ...
         '-i "%s" ' ...
         '-c:v libx264 ' ...
         '-pix_fmt yuv420p ' ...
         '"%s"'], ...
        aviFile, ...
        mp4File);


    status = system(ffmpegCommand);


    if status == 0

        fprintf('\n');
        fprintf('============================================\n');
        fprintf('SUCCESS\n');
        fprintf('============================================\n');

        fprintf('\nYour portfolio MP4 is here:\n\n');

        fprintf('%s\n\n',mp4File);


        %% ----------------------------------------------------
        %  Show file size
        %  -----------------------------------------------------

        fileInfo = dir(mp4File);

        if ~isempty(fileInfo)

            fprintf( ...
                'MP4 size: %.2f MB\n', ...
                fileInfo.bytes / 1024 / 1024);

        end


    else

        warning([ ...
            'The AVI was created successfully, ' ...
            'but ffmpeg could not create the MP4.']);

        fprintf('\nYour AVI is still available here:\n');
        fprintf('%s\n',aviFile);

    end

end



%% ============================================================
%  FUNCTIONS
%  ============================================================


function plotGeoLines( ...
    lonData, ...
    latData, ...
    lat0, ...
    lon0, ...
    scale, ...
    ax, ...
    color, ...
    width)


if iscell(lonData) && iscell(latData)

    n = min( ...
        numel(lonData), ...
        numel(latData));

    for k = 1:n

        [X,Y] = geoToXY( ...
            lonData{k}, ...
            latData{k}, ...
            lat0, ...
            lon0, ...
            scale);

        if ~isempty(X)

            plot3( ...
                ax, ...
                X, ...
                Y, ...
                zeros(size(X)), ...
                'Color',color, ...
                'LineWidth',width);

        end

    end

    return;

end


[X,Y] = geoToXY( ...
    lonData, ...
    latData, ...
    lat0, ...
    lon0, ...
    scale);


if ~isempty(X)

    plot3( ...
        ax, ...
        X, ...
        Y, ...
        zeros(size(X)), ...
        'Color',color, ...
        'LineWidth',width);

end

end



function patchThames( ...
    data, ...
    lat0, ...
    lon0, ...
    scale, ...
    ax, ...
    color)


[lon,lat] = extractLonLat(data);


if isempty(lon) || isempty(lat)

    return;

end


[X,Y] = geoToXY( ...
    lon, ...
    lat, ...
    lat0, ...
    lon0, ...
    scale);


if isempty(X) || all(~isfinite(X))

    return;

end


Z = zeros(size(X));


patch( ...
    ax, ...
    X, ...
    Y, ...
    Z, ...
    color, ...
    'EdgeColor',color, ...
    'FaceAlpha',0.75, ...
    'LineWidth',0.8);

end



function [lon,lat] = extractLonLat(data)


lon = [];
lat = [];


if isempty(data)

    return;

end


%% ------------------------------------------------------------
% CELL DATA
% -------------------------------------------------------------

if iscell(data)

    if numel(data) == 2 && ...
            isnumeric(data{1}) && ...
            isnumeric(data{2}) && ...
            isvector(data{1}) && ...
            isvector(data{2}) && ...
            numel(data{1}) == numel(data{2}) && ...
            looksGeoPair(data{1},data{2})


        lon = data{1}(:);
        lat = data{2}(:);


        if isLondonLat(lon) && isLondonLon(lat)

            temp = lon;
            lon = lat;
            lat = temp;

        end


        return;

    end


    for k = 1:numel(data)

        [lo,la] = extractLonLat(data{k});


        if ~isempty(lo)

            lon = [lon(:); lo(:); nan];
            lat = [lat(:); la(:); nan];

        end

    end


%% ------------------------------------------------------------
% TABLE DATA
% -------------------------------------------------------------

elseif istable(data)

    numericVars = varfun( ...
        @isnumeric, ...
        data, ...
        'OutputFormat','uniform');


    if any(numericVars)

        A = table2array( ...
            data(:,numericVars));

        [lon,lat] = extractLonLat(A);

    end


%% ------------------------------------------------------------
% STRUCT DATA
% -------------------------------------------------------------

elseif isstruct(data)

    if isscalar(data)

        fn = fieldnames(data);


        lonIdx = findName( ...
            fn, ...
            {'lon','long','longitude','x'});

        latIdx = findName( ...
            fn, ...
            {'lat','latitude','y'});


        if ~isempty(lonIdx) && ~isempty(latIdx)

            lo = data.(fn{lonIdx});
            la = data.(fn{latIdx});

            lo = lo(:);
            la = la(:);

            n = min( ...
                numel(lo), ...
                numel(la));

            lon = lo(1:n);
            lat = la(1:n);


        else

            for k = 1:numel(fn)

                [lo,la] = extractLonLat( ...
                    data.(fn{k}));


                if ~isempty(lo)

                    lon = [lon(:); lo(:); nan];
                    lat = [lat(:); la(:); nan];

                end

            end

        end


    else

        for k = 1:numel(data)

            [lo,la] = extractLonLat(data(k));


            if ~isempty(lo)

                lon = [lon(:); lo(:); nan];
                lat = [lat(:); la(:); nan];

            end

        end

    end


%% ------------------------------------------------------------
% NUMERIC DATA
% -------------------------------------------------------------

elseif isnumeric(data)

    if isvector(data)

        return;

    end


    A = double(data);


    if size(A,2) < 2

        return;

    end


    nc = min(size(A,2),3);

    pairs = nchoosek(1:nc,2);


    for k = 1:size(pairs,1)

        c1 = A(:,pairs(k,1));
        c2 = A(:,pairs(k,2));


        if isLondonLat(c1) && isLondonLon(c2)

            lat = c1;
            lon = c2;

            return;

        end


        if isLondonLat(c2) && isLondonLon(c1)

            lat = c2;
            lon = c1;

            return;

        end

    end


    % Fallback
    lon = A(:,1);
    lat = A(:,2);

end


lon = lon(:);
lat = lat(:);

end



function [X,Y] = geoToXY( ...
    lon, ...
    lat, ...
    lat0, ...
    lon0, ...
    scale)


lon = double(lon);
lat = double(lat);


if ~isequal(size(lon),size(lat))

    if numel(lon) == numel(lat)

        lat = reshape( ...
            lat, ...
            size(lon));

    else

        n = min( ...
            numel(lon), ...
            numel(lat));

        lon = lon(1:n);
        lat = lat(1:n);

    end

end


% Check whether latitude and longitude have been reversed
if isLondonLat(lon(:)) && isLondonLon(lat(:))

    temp = lon;

    lon = lat;
    lat = temp;

end


% Convert coordinates to local X/Y system
X = (lon - lon0) .* cosd(lat0) * scale;

Y = (lat - lat0) * scale;

end



function tf = looksGeoPair(a,b)


a = a(:);
b = b(:);


tf = ...
    (isLondonLat(a) && isLondonLon(b)) || ...
    (isLondonLat(b) && isLondonLon(a));

end



function tf = isLondonLat(v)


v = v(isfinite(v));

tf = false;


if isempty(v)

    return;

end


tf = mean( ...
    v >= 50 & ...
    v <= 53) > 0.8;

end



function tf = isLondonLon(v)


v = v(isfinite(v));

tf = false;


if isempty(v)

    return;

end


tf = mean( ...
    v >= -2 & ...
    v <= 2) > 0.8;

end



function idx = findName( ...
    names, ...
    pats)


idx = [];


for i = 1:numel(names)

    for j = 1:numel(pats)

        if contains( ...
                names{i}, ...
                pats{j}, ...
                'IgnoreCase',true)

            idx = i;

            return;

        end

    end

end

end



function r = myRange(x)


x = x(:);

x = x(isfinite(x));


if isempty(x)

    r = 0;

else

    r = max(x) - min(x);

end

end