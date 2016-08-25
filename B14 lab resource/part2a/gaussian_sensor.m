% generate N point samples to simulate a sensor corresponding
% to a 2D Gaussian with mean mu, covariance C

function pts = gauss_sensor(mu,C,N)

B=sqrtm(C);
rand('state',sum(100*clock));

% N 2-vectors for pts with elements chosen from a Normal distribution
% with mean zero and variance one
p = randn(2,N);

% affine transform to target Normal distribution 
% with mean (mx,my) and covariance matric C
pts = B*p + diag(mu) * ones(2,N);

