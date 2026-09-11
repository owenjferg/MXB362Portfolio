fid = fopen('stag_beetle_832x832x494_uint16.raw','r');

data = fread(fid, 832*832*494, 'uint16');

fclose(fid);

D = reshape(data, [832, 832, 494]);
D = D(1:3:end, 1:3:end, end: -3:1);

surface = isosurface(D, 400);

p = patch(surface, 'FaceColor', 'red', 'EdgeColor', 'none');

lighting gouraud
axis equal vis3d off
set(gcf,'color','w')

v = VideoWriter('stag_beetle_rotation.mp4', 'MPEG-4');
v.FrameRate = 30;
open(v);

for t = 1:720
    view([-75+t,19])
    delete(L)
    L = camlight;

    drawnow
    frame = getframe(gcf);
    writeVideo(v, frame);
end