# Run this from the extracted project folder.
use_ggquiver <- all(vapply(c("pracma", "ggplot2", "ggquiver"),
                          requireNamespace, logical(1), quietly = TRUE))
dir.create("outputs", showWarnings = FALSE)

save_plot <- function(name, draw, width = 8, height = 7) {
  pdf(file.path("outputs", paste0(name, ".pdf")), width, height)
  draw()
  dev.off()
  if (capabilities("png")) {
    png(file.path("outputs", paste0(name, ".png")), width = width,
        height = height, units = "in", res = 180)
    draw()
    dev.off()
  }
}

# Task 1
sp <- 0.1
x_points <- seq(-2, 2, by = sp)
y_points <- seq(-1.5, 1.5, by = sp)
X <- matrix(x_points, length(y_points), length(x_points), byrow = TRUE)
Y <- matrix(y_points, length(y_points), length(x_points))
Z <- X * exp(-X^2 - Y^2)
if (use_ggquiver) {
  grad <- pracma::gradient(Z, h1 = sp, h2 = sp)
} else {
  dx <- dy <- Z * 0
  dx[, 2:(ncol(Z)-1)] <- (Z[, 3:ncol(Z)] - Z[, 1:(ncol(Z)-2)]) / (2*sp)
  dy[2:(nrow(Z)-1), ] <- (Z[3:nrow(Z), ] - Z[1:(nrow(Z)-2), ]) / (2*sp)
  dx[, 1] <- (Z[, 2] - Z[, 1]) / sp
  dx[, ncol(Z)] <- (Z[, ncol(Z)] - Z[, ncol(Z)-1]) / sp
  dy[1, ] <- (Z[2, ] - Z[1, ]) / sp
  dy[nrow(Z), ] <- (Z[nrow(Z), ] - Z[nrow(Z)-1, ]) / sp
  grad <- list(X = dx, Y = dy)
}
quiver_data <- data.frame(x = as.vector(X), y = as.vector(Y),
                          vx = as.vector(grad$X), vy = as.vector(grad$Y))
quiver_data$speed <- sqrt(quiver_data$vx^2 + quiver_data$vy^2)
if (use_ggquiver) {
  quiver_plot <- ggplot2::ggplot(quiver_data, ggplot2::aes(x, y)) +
    ggquiver::geom_quiver(ggplot2::aes(u = vx, v = vy, colour = speed)) +
    ggplot2::scale_colour_viridis_c(name = "Gradient magnitude") +
    ggplot2::coord_equal() +
    ggplot2::labs(title = "Gradient vector field", x = "x", y = "y") +
    ggplot2::theme_minimal(base_size = 12)
  save_plot("task1_quiver", function() print(quiver_plot), 9, 7)
} else {
  save_plot("task1_quiver", function() {
    par(mar = c(4, 4, 4, 1))
    plot(NA, xlim = c(-2, 2), ylim = c(-1.5, 1.5), asp = 1,
         xlab = "x", ylab = "y", main = "Gradient vector field",
         sub = "Arrow length shows gradient magnitude (scale factor 0.18)")
    with(quiver_data, {
      keep <- speed > 0.005
      arrows(x[keep], y[keep], x[keep] + 0.18*vx[keep],
             y[keep] + 0.18*vy[keep], length = 0.035, col = "#176B87")
    })
  }, 9, 7)
}

# Tasks 2 and 3 use matrix[x, y].
inside <- function(x, y, field) {
  is.finite(x) & is.finite(y) & x >= 1 & x <= nrow(field) &
    y >= 1 & y <= ncol(field)
}

sample_field <- function(field, x, y) {
  i <- pmin(floor(x), nrow(field) - 1L)
  j <- pmin(floor(y), ncol(field) - 1L)
  a <- x - i
  b <- y - j
  (1-a)*(1-b)*field[cbind(i,j)] + a*(1-b)*field[cbind(i+1,j)] +
    (1-a)*b*field[cbind(i,j+1)] + a*b*field[cbind(i+1,j+1)]
}

velocity <- function(x, y, vx, vy, normalise) {
  u <- sample_field(vx, x, y)
  v <- sample_field(vy, x, y)
  speed <- sqrt(u^2 + v^2)
  if (normalise) {
    u <- u / pmax(speed, 1e-12)
    v <- v / pmax(speed, 1e-12)
  }
  list(u = u, v = v, moving = is.finite(speed) & speed > 1e-12)
}

# Use the midpoint velocity for a smoother path.
advance <- function(x, y, vx, vy, h, normalise = FALSE) {
  nx <- ny <- rep(NA_real_, length(x))
  ids <- which(inside(x, y, vx))
  if (!length(ids)) return(list(x = nx, y = ny))
  vel <- velocity(x[ids], y[ids], vx, vy, normalise)
  mx <- x[ids] + h * vel$u / 2
  my <- y[ids] + h * vel$v / 2
  keep <- inside(mx, my, vx) & vel$moving
  ids <- ids[keep]
  if (!length(ids)) return(list(x = nx, y = ny))
  mid <- velocity(mx[keep], my[keep], vx, vy, normalise)
  tx <- x[ids] + h * mid$u
  ty <- y[ids] + h * mid$v
  keep <- inside(tx, ty, vx) & mid$moving
  nx[ids[keep]] <- tx[keep]
  ny[ids[keep]] <- ty[keep]
  list(x = nx, y = ny)
}

trace_lines <- function(seeds, vx, vy, steps, h, direction) {
  xs <- ys <- matrix(NA_real_, steps + 1L, nrow(seeds))
  xs[1, ] <- seeds$x
  ys[1, ] <- seeds$y
  for (k in seq_len(steps)) {
    pos <- advance(xs[k, ], ys[k, ], vx, vy, direction * h)
    xs[k+1, ] <- pos$x
    ys[k+1, ] <- pos$y
    if (all(is.na(pos$x))) break
  }
  list(x = xs, y = ys)
}

Vx <- readRDS("data/Vx.RDS")
Vy <- readRDS("data/Vy.RDS")
stopifnot(is.matrix(Vx), identical(dim(Vx), c(400L, 400L)),
          identical(dim(Vx), dim(Vy)), all(is.finite(Vx)), all(is.finite(Vy)))

stream_plot <- function(seeds, steps, h, title, subtitle, name) {
  forward <- trace_lines(seeds, Vx, Vy, steps, h, 1)
  backward <- trace_lines(seeds, Vx, Vy, steps, h, -1)
  visited <- matrix(FALSE, nrow(Vx), ncol(Vx))
  for (path in list(forward, backward)) {
    valid <- is.finite(path$x) & is.finite(path$y)
    visited[cbind(round(path$x[valid]), round(path$y[valid]))] <- TRUE
  }
  saveRDS(visited, file.path("outputs", paste0(name, "_visited.RDS")))
  draw <- function() {
    par(mar = c(4, 4, 4, 1))
    plot(NA, xlim = c(1, 400), ylim = c(1, 400), asp = 1,
         xlab = "x", ylab = "y", main = title, sub = subtitle)
    for (i in seq_len(nrow(seeds))) {
      lines(backward$x[, i], backward$y[, i], col = "#176B87", lwd = 0.7)
      lines(forward$x[, i], forward$y[, i], col = "#176B87", lwd = 0.7)
    }
    points(seeds$x, seeds$y, pch = 16, cex = 0.25, col = "#C45B28")
  }
  save_plot(name, draw)
}

poor_seeds <- expand.grid(x = seq(100, 300, by = 100), y = seq(100, 300, by = 100))
good_seeds <- expand.grid(x = seq(15, 385, by = 20), y = seq(15, 385, by = 20))
stream_plot(poor_seeds, 20, 0.5, "Streamlines: poor coverage",
            "9 seeds, 20 steps each way, step size 0.5", "task2_poor_streamlines")
stream_plot(good_seeds, 600, 0.5, "Streamlines: improved coverage",
            "361 seeds, 600 steps each way, step size 0.5", "task2_good_streamlines")

# Task 3
x_points <- y_points <- seq_len(400)
X <- matrix(x_points, 400, 400)
Y <- matrix(y_points, 400, 400, byrow = TRUE)
lic_vx <- X * (-Y + 200 - X)
lic_vy <- Y * (X + 200 - Y)
set.seed(362)
noise <- matrix(runif(400 * 400), 400, 400)

compute_lic <- function(vx, vy, texture, steps = 30, h = 1) {
  seeds <- expand.grid(x = seq_len(nrow(vx)), y = seq_len(ncol(vx)))
  total <- as.vector(texture)
  count <- rep(1L, nrow(seeds))
  for (direction in c(-1, 1)) {
    x <- seeds$x
    y <- seeds$y
    for (k in seq_len(steps)) {
      pos <- advance(x, y, vx, vy, direction * h, normalise = TRUE)
      x <- pos$x
      y <- pos$y
      ids <- which(is.finite(x) & is.finite(y))
      if (!length(ids)) break
      total[ids] <- total[ids] + texture[cbind(round(x[ids]), round(y[ids]))]
      count[ids] <- count[ids] + 1L
    }
  }
  matrix(total / count, nrow(vx), ncol(vx))
}

LIC <- compute_lic(lic_vx, lic_vy, noise)
stopifnot(all(is.finite(LIC)), all(LIC >= 0 & LIC <= 1))
saveRDS(LIC, "outputs/task3_lic.RDS")
limits <- quantile(LIC, c(0.01, 0.99))
lic_display <- pmin(pmax(LIC, limits[1]), limits[2])
save_plot("task3_lic", function() {
  par(mar = c(4, 4, 4, 1))
  image(x_points, y_points, lic_display, col = gray.colors(256, 0, 1),
        useRaster = TRUE, asp = 1, xlab = "x", ylab = "y",
        main = "Line integral convolution",
        sub = "30 steps each way, unit velocity, step size 1")
})
save_plot("task3_noise", function() {
  image(x_points, y_points, noise, col = gray.colors(256, 0, 1),
        useRaster = TRUE, asp = 1, xlab = "x", ylab = "y", main = "Starting white noise")
})
writeLines(capture.output(sessionInfo()), "outputs/session_info.txt")
message("Finished. Plots are saved in outputs.")
