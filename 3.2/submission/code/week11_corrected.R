# Run from 3.2/week11. Original pract1.R remains unchanged.
library(paletteer)
library(ggplot2)
colors <- paletteer_d("ochRe::lorikeet", n = 3)
data(iris)
speciesID <- as.numeric(iris$Species)
out <- "../submission/figures"
start_plot <- function(name) {
  png(file.path(out, paste0(name, ".png")), width=1800, height=1350, res=180)
}
# Task 1: each distinct numerical pair, coloured and marked by species.
start_plot("week11_pairs")
pairs(iris[,1:4], col=colors[speciesID], pch=speciesID, lower.panel=NULL)
par(xpd=NA)
legend("bottomleft", col=colors, pch=1:3, legend=levels(iris$Species))
dev.off()
# Task 2: mean-centred covariance PCA, matching the practical.
X <- scale(as.matrix(iris[,1:4]), center=TRUE, scale=FALSE)
Eigen <- eigen(cov(X))
Z <- X %*% Eigen$vectors[,1:2]
start_plot("week11_pca")
plot(Z, col=colors[speciesID], pch=speciesID,
     xlab="Principal Component 1", ylab="Principal Component 2", main="PCA of Iris Data")
legend("topright", col=colors, pch=1:3, legend=levels(iris$Species))
dev.off()
# Tasks 3-4: search unit vectors to maximise Fisher's criterion.
# Slides 6-7 request columns 1 and 3; final task slide says first two.
# Supply both interpretations explicitly.
results <- character()
for (cols in list(c(1,3), c(1,2))) {
  X <- scale(as.matrix(iris[,cols]))
  Sigma <- cov(X)
  Sigma_b <- matrix(0,2,2)
  for (k in 1:3) {
    delta <- colMeans(X[speciesID==k,]) - colMeans(X)
    Sigma_b <- Sigma_b + tcrossprod(delta)/3
  }
  fisher <- function(w) as.numeric(t(w)%*%Sigma_b%*%w / (t(w)%*%Sigma%*%w))
  angles <- seq(0,pi,length.out=1000)
  J <- vapply(angles, function(a) fisher(c(cos(a),sin(a))), numeric(1))
  best <- which.max(J)
  W <- c(cos(angles[best]),sin(angles[best]))
  W <- W/sqrt(sum(W^2))
  Y <- as.vector(X%*%W)
  tag <- if (cols[2]==3) "main" else "first_two"
  results <- c(results, paste("Variables:",paste(colnames(X),collapse=", ")),
               sprintf("W = [%.8f; %.8f]",W[1],W[2]), sprintf("J(W) = %.8f",fisher(W)), "")
  start_plot(paste0("week11_lda_direction_",tag))
  plot(X, col=colors[speciesID], pch=speciesID,
       xlab=paste("Standardised",colnames(X)[1]),
       ylab=paste("Standardised",colnames(X)[2]), main="LDA Projection Direction")
  lines(c(-2*W[1],2*W[1]),c(-2*W[2],2*W[2]),lwd=2)
  legend("topright",col=colors,pch=1:3,legend=levels(iris$Species))
  dev.off()
  start_plot(paste0("week11_lda_histogram_",tag))
  d <- data.frame(Projection=Y,Species=iris$Species)
  print(ggplot(d,aes(Projection,fill=Species))+
    geom_histogram(colour="grey50",alpha=0.4,position="identity",bins=20)+
    scale_fill_manual(values=colors)+
    labs(title=paste("LDA:",paste(colnames(X),collapse=" and ")),
         x="Projection onto W",y="Count"))
  dev.off()
}
writeLines(results,file.path(out,"week11_lda_results.txt"))
print(results)
