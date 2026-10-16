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

filename = "Pendulum.gif";

if isfile(filename)
    delete(filename)
end

for t = 1:height(X)

    for i = 1:n
        lines{i}.YData = [0 X(t,i)];
        lines{i}.ZData = [0 Y(t,i)];

        markers{i}.YData = X(t,i);
        markers{i}.ZData = Y(t,i);
    end

    drawnow

    frame = getframe(h);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);

    if t == 1
        imwrite(imind, cm, filename, 'gif', ...
            'LoopCount', inf, ...
            'DelayTime', 0.02);
    else
        imwrite(imind, cm, filename, 'gif', ...
            'WriteMode', 'append', ...
            'DelayTime', 0.02);
    end

end
