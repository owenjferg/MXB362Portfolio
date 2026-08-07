niter = 30;

%def search area
x0 = -2; x1 = 2;
y0 = -2; y1 = 2;

%def grid
res = 1000;
X = linspace(x0,x1,res);
Y = linspace(y0,y1,res);
[x,y] = meshgrid(X,Y);

c = x + 1i * y;

%init z value
z = zeros(size(c));
k = zeros(size(c));

%repeat apply to map
for ii = 1:niter
    z = z.^2 + c;

    %color grid if still bound
    k(abs(z) > 2 & k == 0) = niter - ii;
end

figure(4), clf
colormap hot
imagesc(X,Y,k);
axis square
set(gca,'xtick',[],'ytick',[])

niter = 200;
G = 6.5e-4;
Center = [-0.7453 0.1127];
x0 = Center(1) - G; x1 = Center(1) + G;
y0 = Center(2) - G; y1 = Center(2) + G;

% Redefine grid with new limits
X = linspace(x0, x1, res);
Y = linspace(y0, y1, res);
[x, y] = meshgrid(X, Y);

c = x + 1i * y;

% Reinitialize z and k for new iteration
z = zeros(size(c));
k = zeros(size(c));

% Repeat the mapping process for the new grid
for ii = 1:niter
    z = z.^2 + c;
    k(abs(z) > 2 & k == 0) = niter - ii;
end
figure(5), clf
colormap hot
imagesc(X, Y, k);
axis square
set(gca, 'xtick', [], 'ytick', []);

%third plot
niter = 200;
G = 60.5e-4;
Center = [-0.7453 0.1127];
x0 = Center(1) - G; x1 = Center(1) + G;
y0 = Center(2) - G; y1 = Center(2) + G;

% Redefine grid with new limits
X = linspace(x0, x1, res);
Y = linspace(y0, y1, res);
[x, y] = meshgrid(X, Y);

c = x + 1i * y;

% Reinitialize z and k for new iteration
z = zeros(size(c));
k = zeros(size(c));

% Repeat the mapping process for the new grid
for ii = 1:niter
    z = z.^2 + c;
    k(abs(z) > 2 & k == 0) = niter - ii;
end

figure(6), clf
colormap hot
imagesc(X, Y, k);
axis square
set(gca, 'xtick', [], 'ytick', []);