clear;
clc;
close all;

outputDir = fullfile(getenv('HOME'), 'UNI', 'MXB362', 'week5');

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

gifFile = fullfile(outputDir, 'pendulum_animation.gif');

% Delete old GIF if it already exists
if exist(gifFile, 'file')
    delete(gifFile);
end

g = 9.81;              % gravity
N = 5;                 % number of pendulums
Lvals = linspace(0.8, 1.5, N);   % lengths of pendulums
alpha0 = deg2rad(20) * ones(N,1); % initial angle
omega0 = zeros(N,1);              % initial angular velocity
tspan = 0:0.03:10;                % times to evaluate

delayTime = 0.03;

solutions = cell(N,1);

for i = 1:N
    Li = Lvals(i);

    odefun = @(t,y) [y(2); -(g/Li)*y(1)];
    y0 = [alpha0(i); omega0(i)];

    [~, y] = ode45(odefun, tspan, y0);

    solutions{i} = y;
end

fig = figure('Name', 'Pendulum Animation', ...
    'Color', 'w', ...
    'Position', [100 100 900 700]);

ax = axes('Parent', fig);
hold(ax, 'on');
axis(ax, 'equal');
grid(ax, 'on');
box(ax, 'on');

xlim(ax, [-max(Lvals)*1.2, max(Lvals)*1.2]);
ylim(ax, [-max(Lvals)*1.5, max(Lvals)*0.5]);

xlabel(ax, 'x');
ylabel(ax, 'y');
title(ax, 'Pendulum animation');

for k = 1:length(tspan)

    cla(ax);
    hold(ax, 'on');
    axis(ax, 'equal');
    grid(ax, 'on');
    box(ax, 'on');

    xlim(ax, [-max(Lvals)*1.2, max(Lvals)*1.2]);
    ylim(ax, [-max(Lvals)*1.5, max(Lvals)*0.5]);

    for i = 1:N

        alpha = solutions{i}(k,1);

        xBob = Lvals(i) * sin(alpha);
        yBob = -Lvals(i) * cos(alpha);

        % Draw rod
        plot(ax, [0 xBob], [0 yBob], 'LineWidth', 2);

        % Draw bob
        plot(ax, xBob, yBob, 'o', ...
            'MarkerSize', 8, ...
            'MarkerFaceColor', 'b', ...
            'MarkerEdgeColor', 'k');
    end

    % Draw pivot
    plot(ax, 0, 0, 'ks', 'MarkerFaceColor', 'k', 'MarkerSize', 8);

    title(ax, sprintf('t = %.2f s', tspan(k)));

    drawnow;

    % Capture frame
    frame = getframe(fig);
    im = frame2im(frame);
    [imind, cmap] = rgb2ind(im, 256);

    % Write GIF
    if k == 1
        imwrite(imind, cmap, gifFile, 'gif', ...
            'LoopCount', Inf, ...
            'DelayTime', delayTime);
    else
        imwrite(imind, cmap, gifFile, 'gif', ...
            'WriteMode', 'append', ...
            'DelayTime', delayTime);
    end

    fprintf('Frame %d of %d complete\n', k, length(tspan));
end

fprintf('\nPendulum GIF created successfully:\n%s\n', gifFile);