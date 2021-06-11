data {
  int T; // Length of time interval
  vector[T] t; // time vector
  vector[T] Y; // Time Series // Need to update so it can have multple demes

  int K; // Number of features
  matrix[T, K] features; // Features 
}

parameters {
  vector[K] b;
  real<lower=0> sigma;
}

transformed parameters{
  vector[T] EY = features * b;
}

model {
  // ADD_MORE_PRIORS
  sigma ~ exponential(0.5);
  
  Y ~ normal(EY, sigma);
}
