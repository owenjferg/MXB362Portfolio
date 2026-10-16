fid = fopen('stag_beetle_832x832x494_uint16.raw','r');

data = fread(fid, 832*832*494, 'uint16');

fclose(fid);

D = reshape(data, [832, 832, 494]);
D = D(1:3:end, 1:3:end, end:-3:1);

surface = isosurface(D, 400);

p = patch(surface, 'FaceColor', 'red', 'EdgeColor', 'none');

lighting gouraud
axis equal vis3d off
set(gcf,'color','w')

hLight = camlight('headlight');

videoFile = fullfile(fileparts(mfilename('fullpath')), ...
    'stag_beetle_rotation.mp4');

vid = VideoWriter(videoFile, 'MPEG-4');
vid.FrameRate = 40;
vid.Quality = 100;

open(vid);

for t = 1:720
    view([-75+t, 19])

    camlight(hLight, 'headlight')

    drawnow

    frame = getframe(gcf);
    writeVideo(vid, frame);
end

close(vid);

disp(['Video saved to: ' videoFile])