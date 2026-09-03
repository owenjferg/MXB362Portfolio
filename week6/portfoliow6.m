clear;
close all;
clc;

%% 0. Paths and supplied data
baseDir = '/home/owen/UNI/MXB362/Portfolio Things/week6';
outputDir = fullfile(baseDir, 'portfolio_outputs');

if ~isfolder(baseDir)
    error(['The Week 6 folder does not exist:\n  %s\n' ...
           'Create it or change baseDir at the top of this script.'], baseDir);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

% If the supplied ZIP is still compressed, extract it automatically.
zipPath = fullfile(baseDir, 'Volume_Visualisation_I_files.zip');
dataDir = fullfile(baseDir, 'Volume_Visualisation_I_files');

if ~isfolder(dataDir) && isfile(zipPath)
    fprintf('Extracting supplied Week 6 data files...\n');
    unzip(zipPath, baseDir);
end

diFile       = resolveDataFile(baseDir, 'DiCubic.mat');
aneurismFile = resolveDataFile(baseDir, 'aneurism.mat');
toothFile    = resolveDataFile(baseDir, 'ctTooth128x128x256.mat');

fprintf('Using data files:\n');
fprintf('  %s\n', diFile);
fprintf('  %s\n', aneurismFile);
fprintf('  %s\n\n', toothFile);

%% 1. Slides 2-3: Simple volume renderer (sum/average and MIP)
% The slide first forms an X-ray-like image by accumulating values along Z.
% It then asks for Maximum Intensity Projection (MIP).

diData = load(diFile);
Di = single(diData.Di);

fprintf('Di size: %s\n', mat2str(size(Di)));

% Slide 2: sum through all z slices.
diSum = sum(Di, 3);

% MIP: retain the maximum sample encountered on each Z ray.
diMIP = max(Di, [], 3);

fig = figure('Name', 'DiCubic simple volume rendering', 'Color', 'w');
subplot(1, 2, 1);
imagesc(diSum);
axis image off;
colormap(gray(256));
title('DiCubic: summed Z rays (X-ray style)');

subplot(1, 2, 2);
imagesc(diMIP);
axis image off;
colormap(gray(256));
title('DiCubic: Maximum Intensity Projection');

saveFigure(fig, fullfile(outputDir, 'support_Di_sum_and_MIP.png'));

%% 2. Slide 3: Aneurism average-value and MIP rendering
aneurismData = load(aneurismFile);

if ~isfield(aneurismData, 'A')
    error('Expected variable A in aneurism.mat.');
end

Araw = aneurismData.A;

% The supplied file stores the 256^3 scan as a vector.
if isvector(Araw)
    sideLength = round(nthroot(numel(Araw), 3));
    if sideLength^3 ~= numel(Araw)
        error('Aneurism data cannot be reshaped into a cubic 3-D volume.');
    end
    A = reshape(Araw, [sideLength, sideLength, sideLength]);
else
    A = Araw;
end
A = single(A);

fprintf('Aneurism volume size: %s\n', mat2str(size(A)));

aneurismAverage = mean(A, 3);
aneurismMIP = max(A, [], 3);

fig = figure('Name', 'Aneurism average and MIP', 'Color', 'w');
subplot(1, 2, 1);
imagesc(aneurismAverage);
axis image off;
colormap(gray(256));
title('Aneurism: average-value (X-ray)');

subplot(1, 2, 2);
imagesc(aneurismMIP);
axis image off;
colormap(gray(256));
title('Aneurism: MIP');

saveFigure(fig, fullfile(outputDir, 'support_aneurism_average_and_MIP.png'));

%% 3. Slides 5-6: Front-to-back compositing renderer
% Front-to-back recursion from the practical:
%
%   C_out     = C_in + (1 - alpha_in) * alpha_i * C_i
%   alpha_out = alpha_in + (1 - alpha_in) * alpha_i
%
% For grayscale rendering, colour is proportional to the data value.
% Opacity is also proportional to the data value.

A01 = normalise01(A);
aneurismComposite = compositeVolume(A01, A01, 3, false);

fig = figure('Name', 'Aneurism front-to-back composite', 'Color', 'w');
imagesc(aneurismComposite);
axis image off;
colormap(gray(256));
title('Aneurism: front-to-back compositing');
saveFigure(fig, fullfile(outputDir, 'support_aneurism_composite.png'));

% A is no longer needed. Freeing it keeps memory use lower before the
% portfolio tasks.
clear A A01 Araw aneurismAverage aneurismMIP aneurismComposite;

%% 4. PORTFOLIO TASK 1 - MRI volume sculpting with half-cylinder cutout
% Slide 7 asks for a half cylinder of radius 50.
%
% From the diagram:
%   - X = 1:256
%   - Y = 1:256
%   - Z = 1:54
%   - cylinder axis runs parallel to Y
%   - cylinder centre is at X = 128 on the Z = 54 boundary
%   - radius = 50
%
% Because the centre lies on the Z=54 boundary, only the half of the
% circular cross-section that lies inside the volume is present.
%
% Volume sculpting is performed by setting opacity to zero inside that
% half-cylinder; the MRI intensities themselves are left unchanged.

radius = 50;
xCentre = 128;
zCentre = size(Di, 3);       % 54 for the supplied Di volume

% Slide 5 defines alpha = Di/maxDi. The supplied MRI includes a few small
% negative values, so they are clamped to zero before becoming opacity.
DiPositive = max(Di, 0);
maxDi = max(DiPositive(:));

if maxDi == 0
    error('Di volume contains no positive intensity values.');
end

alphaDi = DiPositive ./ maxDi;
colourDi = normalise01(DiPositive);

% Build the X-Z circular cross-section, then extend it through every Y.
[xGrid, zGrid] = ndgrid(1:size(Di, 1), 1:size(Di, 3));
cylinderXZ = ((xGrid - xCentre).^2 + (zGrid - zCentre).^2) <= radius^2;

cutMask = repmat(reshape(cylinderXZ, ...
    [size(Di, 1), 1, size(Di, 3)]), ...
    [1, size(Di, 2), 1]);

alphaSculpted = alphaDi;
alphaSculpted(cutMask) = 0;

% Render through Z in both directions. These are the two sides requested by
% the practical. Keeping the ray direction in the title makes orientation
% unambiguous.
mriTop = compositeVolume(colourDi, alphaSculpted, 3, false); % z = 1 -> 54
mriBottom = compositeVolume(colourDi, alphaSculpted, 3, true); % z = 54 -> 1

fig = figure('Name', 'PORTFOLIO Task 1 - MRI cylindrical cutout', 'Color', 'w');
subplot(1, 2, 1);
imagesc(mriTop);
axis image off;
colormap(gray(256));
title('Top view: Z = 1 \rightarrow 54');

subplot(1, 2, 2);
imagesc(mriBottom);
axis image off;
colormap(gray(256));
title('Bottom view: Z = 54 \rightarrow 1');

sgtitle('Portfolio Task 1: MRI with radius-50 half-cylinder cutout');

saveFigure(fig, fullfile(outputDir, ...
    'PORTFOLIO_TASK1_MRI_cylindrical_cutout.png'));

%% 5. PORTFOLIO TASK 2 - Tooth middle slice
% Slide 8 supplies the following R steps:
%   slice <- ctTooth128x128x256[64,,]
%   rotated_slice <- t(apply(slice, 2, rev))
%
% MATLAB equivalent:
%   squeeze the X=64 slice,
%   reverse its rows,
%   then transpose it.

toothData = load(toothFile);

if ~isfield(toothData, 'ctTooth128x128x256')
    error('Expected variable ctTooth128x128x256 in the tooth MAT file.');
end

tooth = single(toothData.ctTooth128x128x256);
fprintf('Tooth volume size: %s\n', mat2str(size(tooth)));

middleSlice = squeeze(tooth(64, :, :));
rotatedSlice = flipud(middleSlice).';

fig = figure('Name', 'PORTFOLIO Task 2 - Tooth slice', 'Color', 'w');
imagesc(rotatedSlice);
axis image off;
colormap(gray(256));
title('Portfolio Task 2: Tooth slice at X = 64');

saveFigure(fig, fullfile(outputDir, ...
    'PORTFOLIO_TASK2_tooth_slice.png'));

%% 6. Slide 8 supporting step - naive tooth compositing along Y
% This deliberately maps both grayscale colour and opacity directly to the
% normalised data value. As the slide explains, the surrounding material
% becomes too opaque and obscures the tooth.

tooth01 = normalise01(tooth);
toothNaive = compositeVolume(tooth01, tooth01, 2, false);

fig = figure('Name', 'Tooth naive compositing', 'Color', 'w');
imagesc(toothNaive);
axis image off;
colormap(gray(256));
title('Tooth: naive colour/opacity mapping along Y');
saveFigure(fig, fullfile(outputDir, 'support_tooth_naive_composite.png'));

%% 7. PORTFOLIO TASK 3 - Piecewise-linear opacity transfer function
% Slide 9 asks for:
%   - a 256-entry opacity transfer function,
%   - classification of each voxel into that lookup table,
%   - compositing along Y,
%   - a final render clearer than the naive result.
%
% R uses trunc(...). MATLAB's fix(...) also rounds toward zero, so it is
% used below to reproduce the classification rule from the slide.

L = 256;
transFunc = zeros(1, L, 'single');

% -------------------------------------------------------------------------
% TRANSFER FUNCTION TO TUNE
% -------------------------------------------------------------------------
% The tooth is surrounded by a material concentrated around intensity ~80.
% The first 100 lookup entries are therefore transparent. Higher values are
% introduced with smooth linear ramps so the tooth becomes visible while
% retaining some internal intensity variation.
%
% You can adjust these ramps if you want a different final appearance.
transFunc(1:100)   = 0;
transFunc(101:150) = linspace(0.00, 0.10, 50);
transFunc(151:190) = linspace(0.10, 0.05, 40);
transFunc(191:230) = linspace(0.05, 0.30, 40);
transFunc(231:256) = linspace(0.30, 0.60, 26);
% -------------------------------------------------------------------------

minMRI = min(tooth(:));
maxMRI = max(tooth(:));
lenMRI = maxMRI - minMRI;

if lenMRI == 0
    error('Tooth volume has zero intensity range.');
end

% Slide formula:
% opacityIndex = trunc((volVal-minMRI)/lenMRI*(L-1))+1;
opacityIndex = fix((tooth - minMRI) ./ lenMRI .* (L - 1)) + 1;

% Numerical safety: ensure all indices are valid MATLAB indices.
opacityIndex = max(1, min(L, opacityIndex));

% Map every voxel through the 1-D opacity transfer function.
alphaTooth = reshape(transFunc(opacityIndex(:)), size(tooth));

% Grayscale colour remains proportional to CT intensity.
colourTooth = tooth01;

% Slide 8 notes that compositing along Y produces the best result.
toothCustom = compositeVolume(colourTooth, alphaTooth, 2, false);

% Save the transfer function itself. It is useful evidence of the chosen
% piecewise-linear mapping, even though the final slide only explicitly
% requires the code and final render.
fig = figure('Name', 'PORTFOLIO Task 3 - Opacity transfer function', 'Color', 'w');
plot(1:L, transFunc, 'LineWidth', 1.5);
xlim([1 L]);
ylim([0 1]);
grid on;
xlabel('Opacity lookup-table index');
ylabel('\alpha');
title('Chosen piecewise-linear tooth opacity transfer function');
saveFigure(fig, fullfile(outputDir, ...
    'PORTFOLIO_TASK3_opacity_transfer_function.png'));

% Clean final render for the portfolio.
fig = figure('Name', 'PORTFOLIO Task 3 - Tooth render', 'Color', 'w');
imagesc(toothCustom);
axis image off;
colormap(gray(256));
title('Portfolio Task 3: Tooth with custom opacity transfer function');
saveFigure(fig, fullfile(outputDir, ...
    'PORTFOLIO_TASK3_tooth_custom_transfer_render.png'));

%% 8. Finish
fprintf('\nFinished. Portfolio-ready images are in:\n  %s\n\n', outputDir);
fprintf('Use these three outputs in the Week 6 portfolio:\n');
fprintf('  1. PORTFOLIO_TASK1_MRI_cylindrical_cutout.png\n');
fprintf('  2. PORTFOLIO_TASK2_tooth_slice.png\n');
fprintf('  3. PORTFOLIO_TASK3_tooth_custom_transfer_render.png\n');
fprintf('\nThe Task 3 transfer-function plot is also saved as supporting evidence.\n');

%% Local functions

function filePath = resolveDataFile(baseDir, fileName)
%RESOLVEDATAFILE Locate a supplied data file either directly in the Week 6
%folder or in the folder created by extracting the supplied ZIP.

    candidates = {
        fullfile(baseDir, fileName)
        fullfile(baseDir, 'Volume_Visualisation_I_files', fileName)
    };

    filePath = '';
    for ii = 1:numel(candidates)
        if isfile(candidates{ii})
            filePath = candidates{ii};
            return;
        end
    end

    % Final fallback: recursively search below the Week 6 folder.
    matches = dir(fullfile(baseDir, '**', fileName));
    if ~isempty(matches)
        filePath = fullfile(matches(1).folder, matches(1).name);
        return;
    end

    error(['Could not find %s below:\n  %s\n' ...
           'Put Volume_Visualisation_I_files.zip in the Week 6 folder ' ...
           'or extract the supplied data there.'], fileName, baseDir);
end

function V01 = normalise01(V)
%NORMALISE01 Linearly map a numeric array to the range [0,1].

    V = single(V);
    vMin = min(V(:));
    vMax = max(V(:));

    if vMax == vMin
        V01 = zeros(size(V), 'single');
    else
        V01 = (V - vMin) ./ (vMax - vMin);
    end
end

function imageOut = compositeVolume(colourVolume, alphaVolume, rayAxis, reverseOrder)
%COMPOSITEVOLUME Front-to-back grayscale volume compositing.
%
% imageOut = compositeVolume(colourVolume, alphaVolume, rayAxis, reverseOrder)
%
% colourVolume and alphaVolume must be the same 3-D size and should contain
% values in [0,1]. rayAxis selects the traversal axis:
%   1 = X, 2 = Y, 3 = Z
%
% reverseOrder=false traverses index 1 -> end.
% reverseOrder=true  traverses end -> 1.
%
% Recursion:
%   C_out     = C_in + (1-alpha_in)*alpha_i*C_i
%   alpha_out = alpha_in + (1-alpha_in)*alpha_i

    if ~isequal(size(colourVolume), size(alphaVolume))
        error('colourVolume and alphaVolume must have the same size.');
    end

    if ~ismember(rayAxis, [1 2 3])
        error('rayAxis must be 1, 2, or 3.');
    end

    colourVolume = single(colourVolume);
    alphaVolume = single(alphaVolume);

    % Keep values physically meaningful.
    colourVolume = max(0, min(1, colourVolume));
    alphaVolume = max(0, min(1, alphaVolume));

    % Permute so the ray-traversal dimension is first.
    remainingAxes = 1:3;
    remainingAxes(rayAxis) = [];
    permutation = [rayAxis, remainingAxes];

    C = permute(colourVolume, permutation);
    A = permute(alphaVolume, permutation);

    nSamples = size(C, 1);
    imageOut = zeros(size(C, 2), size(C, 3), 'single');
    alphaOut = zeros(size(C, 2), size(C, 3), 'single');

    if reverseOrder
        rayIndices = nSamples:-1:1;
    else
        rayIndices = 1:nSamples;
    end

    for ii = rayIndices
        Ci = reshape(C(ii, :, :), size(C, 2), size(C, 3));
        alphaI = reshape(A(ii, :, :), size(A, 2), size(A, 3));

        remainingTransparency = 1 - alphaOut;
        contribution = remainingTransparency .* alphaI;

        imageOut = imageOut + contribution .* Ci;
        alphaOut = alphaOut + contribution;

        % Optional early ray termination: once every output pixel is nearly
        % opaque, later samples cannot materially change the image.
        if all(alphaOut(:) > 0.995)
            break;
        end
    end
end

function saveFigure(fig, filePath)
%SAVEFIGURE Save a figure to PNG with a compatibility fallback.

    drawnow;

    try
        exportgraphics(fig, filePath, 'Resolution', 200);
    catch
        saveas(fig, filePath);
    end
end