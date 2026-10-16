fid <- file('/home/owen/UNI/MXB362/Portfolio Things/week8/stag_beetle_832x832x494_uint16.raw', 'rb')
beetle_data <- readBin(fid, 'integer', n = 832*832*494, size = 2, signed = FALSE)
close(fid)
beetle_data <- array(beetle_data, dim = c(832, 832, 494))

I <- matrix(1,
            nrow = dim(beetle_data)[1],
            ncol = dim(beetle_data)[2]
)
for (x in 1:dim(beetle_data)[1]) {
  for (y in 1:dim(beetle_data)[2]) {
    I[x,y] <- sum(beetle_data[x, y, ])
  }
}

rotated_I <- t(apply(I, 2, rev))

image(rotated_I, col = gray.colors(256), asp = 1, axes = FALSE, xlab = "", ylab = "")