#install.packages("paletteer")
#install.packages("ggplot2")

library(paletteer)
library(ggplot2)

# Choose three colours because the iris dataset has three species.
colors <- paletteer_d("ochRe::lorikeet", n = 3)

# If you prefer different colours, comment out the line above
# and uncomment the line below.
# colors <- c("#2F5597", "#8B1E1E", "#F2C94C") # Blue, dark red, and yellow

# -----------------------------
# Load and look at the iris data
# -----------------------------

data(iris)

head(iris)       # This helps us understand what variables are in the dataset
# View(iris)     # Uncomment this if you want to view it.

# ============================================
# TASK 1: Pairs plot
# ============================================

# Compare each numerical variable with every other variable
# (the structure of the data before we use it)

pairs(
  iris[, 1:4],
  col = colors[unclass(iris$Species)],  # Give each species a different colour.
  pch = unclass(iris$Species),          # Give each species a different plotting symbol.
  lower.panel = NULL                   # Remove duplicate plots from the lower panel.
)

# Add a legend so we know which colour/symbol represents which species.
par(xpd = NA)

legend(
  "bottomleft",
  col = colors,
  pch = 1:3,
  legend = levels(iris$Species)
)
#task 2 principal component analysis

X = as.matrix(iris[, 1:4])

X = scale(X, center = TRUE, scale = FALSE)

C = cov(X)

Eigen = eigen(C)

z1 = X %*% Eigen$vectors[, 1]
z2 = X %*% Eigen$vectors[, 2]

plot(
  z1,
  z2,
  col = colors[unclass(iris$Species)],
  pch = unclass(iris$Species),
  xlab = "Principal Component 1",
  ylab = "Principal Component 2",
  main = "PCA of Iris Data"
)

legend(
  "topright",
  col = colors,
  pch = 1.3,
  legend = levels(iris$Species)
)

# task 3

X = scale(as.matrix(iris[, c(1, 3)]))

speciesID = as.numeric(iris$Species)

C = max(speciesID)

classMeans = matrix(0, nrow = 2, ncol = C)

for (c in 1:C) {
  classMeans[, c] = colMeans(X[speciesID == c,])
  }

grandMean = matrix(colMeans(X), nrow = 2)

Sigma_b = matrix(0, nrow = 2, ncol = 2)

for (c in 1:c) {
  
  difference = classMeans[, c] - grandMean
  
  Sigma_b = Sigma_b +
    (1 / C) * difference %*% t(difference)
}

Sigma = cov(X)

angles = seq(0, pi, length.out = 1000)

J = numeric(length(angles))

for (i in 1: length(angles)) {
  w = matrix(c(
    cos(angles[1]),
    sin(angles[i])
  ))
  
  J[i] =
    (t(w) %*% Sigma_b %*% w) /
    (t(w) %*% Sigma %*% w)
}

best = which.max(J)

W = matrix(c(
  cos(angles[best]),
  sin(angles[best])
))

J_W = J[best]

cat("Best projection vector W:\n")
print(W)

cat("\nJ(W):\n")
print(J_W)

# task 4

Y = X %*% W

plot(
  X[, 1],
  X[, 2],
  col = colors[unclass(iris$Species)],
  pch = unclass(iris$Species),
  xlab = "Standardised Sepal Length",
  ylab = "Standardised Petal Length",
  main = "LDA Porjection Direction"
)

lines(
  c(-2 * W[1], 2 * W[1]),
  c(-2 * W[2], 2 * W[2]),
  lwd = 2
)

legend(
  "topright",
  col = colors,
  pch = 1:3,
  legend = levels(iris$Species)
)

lda_data = data.frame(
  Projection = as.vector(y), 
  Species = iris$Species
)

ggplot(
  lda_data,
  aes(x = Projection, fill = Species)
) + 
  geom_histogram(
    colour = "grey50",
    alpha = 0.4, 
    position = "identity",
    bins = 20
  ) + 
  scale_fill_manual(values = colors) + 
  labs( x = "Projection onto W", y = "Count", title = "LDA Projection of Iris Data")
