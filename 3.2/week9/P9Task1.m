clear all

figure(1), clf, hold on, box on

load AustOutline_MXB362.mat
pt = patch(Outline(:,1),Outline(:,2),[0.8 0.8 0.8]);
set (pt,'facecolor',[1 0.9 0.65])

load ReefOutline_MXB362.mat
plot(ReefRaw(:,1),ReefRaw(:,2),'b')

xlim([148.5 155]); XL = xlim;
ylim([-25.5 -19.5]); YL = ylim;
set(gca,'color',[0.94 1 1])

load LarvalReleases_MXB362.mat

gifname = 'LarvalDispersal.gif';

nSteps = size(ER_traj_x,1);

for t = 1:nSteps

    x = ER_traj_x(t,:);
    y = ER_traj_y(t,:);

    valid = ~isnan(x) & ~isnan(y);
    x = x(valid);
    y = y(valid);

    P = plot(x,y,'.','markersize',4,'color',[0 0.5 0]);

    if length(x) >= 3
        K = convhull(x,y);
        H = plot(x(K),y(K),'r','linewidth',1.5);
    end

    title(['Larval dispersal - timestep ', num2str(t)])

    drawnow

    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);

    if t == 1
        imwrite(imind,cm,gifname,'gif', ...
            'Loopcount',inf,'DelayTime',0.05);
    else
        imwrite(imind,cm,gifname,'gif', ...
            'WriteMode','append','DelayTime',0.05);
    end

    delete(P)

    if exist('H','var')
        delete(H)
        clear H
    end
end
