r <- 0.25
h <- 0.1
st <- 0.25
K <- 1
TMax <- 50
NumReps <- 2500

simulate_population <- function(z, h, stochastic = TRUE) {
  
  N <- matrix(0.5, nrow = NumReps, ncol = TMax)
  
  for (i in 1:NumReps) {
    for (t in 1:(TMax - 1)) {
      
      if (stochastic) {
        rt <- r * (1 + rnorm(1) * st)
        ht <- h * (1 + rnorm(1) * st)
      } else {
        rt <- r
        ht <- h
      }
      
      N[i, t + 1] <- N[i, t] +
        rt * N[i, t] * (1 - (N[i, t] / K)^z) -
        ht * N[i, t]
    }
  }
  
  return(N)
}

tiff("Fishery_Uncertainty.tiff",
     width = 10,
     height = 8,
     units = "in",
     res = 300,
     compression = "lzw")

par(mfrow = c(3, 1), mar = c(4, 4, 3, 1))

# Demographic uncertainty

N_demo <- simulate_population(z = 1, h = 0.1, stochastic = TRUE)

Q_demo <- apply(N_demo, 2, quantile, probs = c(0.025, 0.5, 0.975))

plot(NA,
     ylim = c(0, 1.25),
     xlim = c(1, TMax),
     xlab = "Time",
     ylab = "Abundance",
     main = "Demographic uncertainty")

polygon(c(1:TMax, TMax:1),
        c(Q_demo[1,], rev(Q_demo[3,])),
        col = rgb(0, 0, 1, 0.25),
        border = NA)

lines(1:TMax, Q_demo[2,], col = "blue", lwd = 2)

legend("topright",
       legend = c("Median", "95% interval"),
       col = c("blue", rgb(0, 0, 1, 0.25)),
       lwd = c(2, 8),
       bty = "n")


# Structural / parametric uncertainty

N_z1 <- simulate_population(z = 1, h = 0.1, stochastic = FALSE)
N_z2 <- simulate_population(z = 2, h = 0.1, stochastic = FALSE)

plot(1:TMax, N_z1[1,],
     type = "l",
     ylim = c(0, 1.25),
     xlim = c(1, TMax),
     xlab = "Time",
     ylab = "Abundance",
     main = "Structural / Parametric uncertainty",
     col = "red",
     lwd = 2)

lines(1:TMax, N_z2[1,],
      col = "darkgreen",
      lwd = 2)

legend("topright",
       legend = c("z = 1", "z = 2"),
       col = c("red", "darkgreen"),
       lwd = 2,
       bty = "n")


# Scenario uncertainty

N_h01 <- simulate_population(z = 1, h = 0.1, stochastic = FALSE)
N_h02 <- simulate_population(z = 1, h = 0.2, stochastic = FALSE)

plot(1:TMax, N_h01[1,],
     type = "l",
     ylim = c(0, 1.25),
     xlim = c(1, TMax),
     xlab = "Time",
     ylab = "Abundance",
     main = "Scenario uncertainty",
     col = "blue",
     lwd = 2)

lines(1:TMax, N_h02[1,],
      col = "red",
      lwd = 2)

legend("topright",
       legend = c("h = 0.1", "h = 0.2"),
       col = c("blue", "red"),
       lwd = 2,
       bty = "n")

dev.off()
