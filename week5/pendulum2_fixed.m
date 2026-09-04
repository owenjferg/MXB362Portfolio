function pendulum2()

outputDir = fullfile(getenv('HOME'),'UNI','MXB362','week5');
if ~exist(outputDir,'dir')
    mkdir(outputDir)
end
filename = fullfile(outputDir,'pendulum_animation.gif');
if exist(filename,'file')
    delete(filename)
end

RecordAnimation = 1;

clear global
global g m L
g = 9.81;

L0 = 1;
LM = 16;
G = 51;

x0 = [pi/6,0];

% Solve the equations of motion for each pendulum
for ll = 1:LM
    L = L0*(G/(G+ll-1)).^2;
    [t,x] = ode45(@DE2,[0:0.05:120],x0);
    Angle = x(:,1);
    Y(:,ll) = -L.*cos(Angle);
    X(:,ll) = L.*sin(Angle);
end

% Initialise the figure
h = figure(1); clf; hold on;
view([-90 -5]); camlight; axis off vis3d
xlim([0 1.2]); ylim([-1.1 1.1]); zlim([-1.1 0]);

PP = patch([1.1 1.1 1.1 1.1],[-1 1 1 -1],[0 0 -1 -1],0.5*ones(1,3));

[Xs,Ys,Zs] = sphere(15);
SS = 0.04; Xs = Xs.*SS; Ys = Ys.*SS; Zs = Zs.*SS;

CL = parula(LM); CL = CL(end:-1:1,:);
Is_3D = 0;

% Create each frame of the animation
for t = 1:length(X)
    for ll = 1:LM

        if Is_3D == 0
            pp(2*(ll)-1) = plot3(ll./LM,X(t,ll),Y(t,ll),'.','markersize',20,'color',CL(ll,:));
            pp(2*(ll)) = plot3([ll ll]./LM,[0 X(t,ll)],[0 Y(t,ll)],'-','markersize',20,'color',0.8.*ones(1,3));
        else
            pp(2*(ll)) = plot3([ll ll]./LM,[0 X(t,ll)],[0 Y(t,ll)],'-','markersize',20,'color',0.2.*ones(1,3));
            pp(2*(ll)-1) = surf(ll./LM+Xs,X(t,ll)+Ys,Y(t,ll)+Zs);
            set(pp(2*(ll)-1),'edgecolor','none','facecolor',CL(ll,:),'ambientstrength',0.04,'DiffuseStrength',0.8);
        end
    end

    if RecordAnimation == 1
        frame = getframe(h);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);

        if t == 1
            imwrite(imind,cm,filename,'gif','Loopcount',inf,'DelayTime',0.02);
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.02);
        end
    end

    drawnow
    if t < length(X)
        delete(pp)
    end
end
end

function dxdt = DE2(t,x)
global g L

dxdt = [x(2); -g/L*sin(x(1))];
end
