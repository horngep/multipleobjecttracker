% Plots mean and elliptical contours at sigma = 1,2 and 3 for 
% a 2D Gaussian with mean mu, covariance C

function plot_contours(mu,C)

B=sqrtm(C);
numpoints   = 200;
theta       = [1:(numpoints+1)] * 2 * pi/numpoints;  % angles
circlepoint = [cos(theta); sin(theta)];              %circle

%
% plot contour ellipses
%

hold on
x1 = 1 * B * circlepoint + mu*ones(1,numpoints+1); % 1 sigma ellipse
plot(x1(1,:), x1(2,:),'r');

x2 = 2 * B * circlepoint + mu*ones(1,numpoints+1); % 2 sigma ellipse
plot(x2(1,:),x2(2,:),'m');

x3 = 3 * B * circlepoint + mu*ones(1,numpoints+1); % 3 sigma ellipse
plot(x3(1,:),x3(2,:),'g');

% plot circle radius r for mean
r = 0.2;
x = r * circlepoint + mu*ones(1,numpoints+1); 
plot(x(1,:),x(2,:),'g');

hold off

