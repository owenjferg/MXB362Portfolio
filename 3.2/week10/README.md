# Week 10: Vector visualisation

## Run the practical

1. Extract the ZIP before opening the files.
2. Open `Week10_Vector_Visualisation.Rproj` in RStudio, then open `week10_vectors.R`.
3. The project sets the working directory automatically. If you opened only the script, select **Session > Set Working Directory > To Source File Location**.
4. For the packages used in the slides, run this once in the Console:

```r
install.packages(c("pracma", "ggplot2", "ggquiver"))
```

5. Click **Source** to run all three tasks. Figures are saved in `outputs` as PDF and PNG when PNG support is available.

The script also works without these packages. In that case, Task 1 uses base R to calculate finite differences and draw arrows. Tasks 2 and 3 always use base R. The data files are included in `data`, so no paths need changing once the working directory is set.

## Files for the portfolio

| Requirement | Figure |
|---|---|
| Task 1: direct vector field | `outputs/task1_quiver.png` |
| Task 2: poor streamline visualisation | `outputs/task2_poor_streamlines.png` |
| Task 2: good streamline visualisation | `outputs/task2_good_streamlines.png` |
| Task 3: line integral convolution | `outputs/task3_lic.png` |

Include `week10_vectors.R` alongside these figures. `task3_noise.png` is an extra figure showing the initial random texture. `task2_*_visited.RDS` records the grid locations visited by streamlines. `task3_lic.RDS` contains the original LIC values before display contrast adjustment.

## Task 1: Quiver plot

The surface is z = x exp(-x² - y²), sampled every 0.1 units. Its gradient gives the x and y components of the vector field. The arrows show the direction of increasing z, with longer arrows indicating a larger gradient. Around x = 0, the arrows mainly point to the right. They spread away from the minimum near (-0.71, 0) and point towards the maximum near (0.71, 0).

The coordinate and velocity matrices are flattened in the same order before plotting. This keeps each arrow matched to its correct position.

## Task 2: Streamlines

Both plots use the supplied Vx and Vy data. Each line follows the field forwards and backwards from its seed. The code interpolates the velocity between grid points and uses a midpoint step to make the curves smoother. A path stops when its next midpoint or endpoint would leave the grid, or when the velocity becomes effectively zero.

| Setting | Poor plot | Improved plot |
|---|---|---|
| Seed placement | 100 to 300, every 100 units on each axis | 15 to 375, every 20 units on each axis |
| Number of seeds | 9 | 361 |
| Maximum steps in each direction | 20 | 600 |
| Step size multiplier | 0.5 | 0.5 |

The poor plot only shows a few short sections of the field. The large gaps and short paths make the overall structure difficult to see. The improved plot spreads seeds across most of the domain and traces them further. This reveals the curved flow and rotating regions, particularly near the lower centre and left of centre. Some lines overlap where the flow converges, so adding more seeds would not necessarily improve the plot.

The orange dots mark the starting positions. These streamline curves show the shape of the flow but do not independently indicate its forward direction.

## Task 3: Line integral convolution

This task uses the new field specified in the slides, rather than the Task 2 data:

```r
Vx = X * (-Y + 200 - X)
Vy = Y * (X + 200 - Y)
```

A random texture is generated with `set.seed(362)` so the result can be reproduced. Every one of the 160,000 grid points becomes a seed. From each seed, the code follows the field for up to 30 steps forwards and 30 backwards, sampling the nearest texture value at each position. The seed value is included once.

The average of these samples becomes the LIC value. Nearby seeds following similar paths produce streaks aligned with the field. The result shows the changing orientation of the field across the domain. Standard symmetric LIC shows orientation, but does not distinguish forward from backward flow.

### Optional extensions completed

- **Boundary correction:** divide by the actual number of samples collected. Paths that stop early therefore do not become artificially dark just because they have fewer samples.
- **Normalised velocity:** divide each interpolated velocity by its magnitude before stepping. This gives approximately one grid unit of travel per step and avoids extremely large jumps in this field.

The displayed image clips values at the 1st and 99th percentiles to make the texture easier to see. This only changes display contrast. The original values are saved separately.

### Matrix orientation

Task 1 follows the slides' landscape layout, with rows representing y and columns representing x. For Tasks 2 and 3, matrices use `[x, y]`, matching the velocity lookup and the X/Y construction on slide 4. R's `image(x, y, z)` already expects this layout, so the LIC image does not need a transpose. Applying the transpose shown on slide 5 to this particular layout would swap the axes.

## Verification

The full script was run successfully using R 4.6.0 through WebR, including the pracma and ggquiver path. All figures were generated by the R code. The base-R fallback was also run successfully. The supplied data passed dimension and finite-value checks, and the LIC result contained only finite values between 0 and 1. Package versions are recorded in `outputs/session_info.txt`.
