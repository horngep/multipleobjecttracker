%%% Matlab script for plotting, measuring and transforming distributions
%%%

%
% specify mean and covariance of the 2D Normal distribution
%

% mean 
mu = [ 5 ; 2];

% covariance matrix
sigma_x  = 2; 		sigma_xy = 0;
sigma_yx = sigma_xy;	sigma_y  = 1;
C = [ sigma_x^2 	sigma_xy;
      sigma_yx		sigma_y^2;
];

% number of samples
N = 1000; 

% generate point samples
pts = gaussian_sensor(mu,C,N);

% plot samples
figure; 
plot(pts(1,:),pts(2,:),'b.'); 
axis equal;

%
% Measure moments of distribution
%

% the mean
M1 = mean(pts,2)

% the second moment matrix
M2 = cov(pts')

% Plot measured Gaussian contour ellipses
plot_contours(M1, M2);

%%%
%%% Affine (i.e. linear) transformation of samples -------------------------
%%% 

A = [ 1, 1; 0, 1 ]; t = [1;1];
ptst = A * pts + diag(t) * ones(2,N); % transformed points

% plot transformed points
figure; 
hold on

plot(ptst(1,:),ptst(2,:),'b.'); % plot transformed (x,y) points
axis equal;

%
% Measure moments of transformed distribution
%

% the mean
M1t = mean(ptst,2)

% the second moment matrix
M2t = cov(ptst')

% Plot measured Gaussian contour ellipses
plot_contours(M1t, M2t);

%
% Compute moments of transformed distribution
%

M1t = A * M1 + t;
M2t = A * M2 * A';

%%%
%%% Sensor fusion and MLE
%%% 

x = [-5:0.1:5];  % this creates a row vector starting at
                 % -5 and going up to 5 in increments of 0.1
y = [-5:0.1:5];
z = normal2d(x, y, [1 1]', [1 0; 0 4]);

contour(x,y,z);
sum(sum(z))

z1givenx = normal2d(x,y,[1 1]', [1 0; 0 4]);
surf(x,y,z1givenx);

z2givenx = normal2d(x,y,[1 0]', [4 0; 0 1]);
surf(x,y,z1givenx);
hold on
surf(x,y,z2givenx);
hold off

z1andz2 = z1givenx .* z2givenx;
hold off
pcolor(x,y,z1andz2);
ginput(1)

[u,v] = argmax(x,y,z1andz2)

%
% non-Gaussian sensor
I1 = imread('background.tif');
figure(2);
colormap gray
imshow(I1);

I2 = imread('foreground.tif');
figure(3);
colormap gray
imshow(I2);

zcam = imsub(I1,I2,30); % 30 is a threshold value
figure(4)
imagesc(zcam);
surf(x,y,zcam);


zfinal = z1andz2 .* zcam;
imagesc(zfinal);
surf(x,y,zfinal);
[u,v] = argmax(x,y,zfinal)

