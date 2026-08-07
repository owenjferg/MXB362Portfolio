figure(3)
clf
hold on
box on

N = 30;                             
for i = 1:N
    s = 10 * 0.93^i;                 % diminishing square half-width
    patch([-s s s -s],[-s -s s s],[i i i i], [0.3 0.6 0.9], ...
        'EdgeColor','k')
end
axis equal
view(35,25)                          % a nice 3-D angle for the still image

% export as JPG
set(gcf,'paperunits','centimeters','paperposition',[0 0 21 30])
print('-djpeg','-r300','stack_of_squares.jpg')