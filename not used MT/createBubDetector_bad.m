

% 0. Setting up
setup;
vidNo = 2;
vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are



% 1. Apply MSER directly to input image
% INPUT: target frame
% OUTPUT: binary image M

I = imread('Image47','jpg');

mser_param = struct(); % setup the parameters for MSER
mser_param.MaxArea = 0.1;    mser_param.MinArea = 0.001; 
mser_param.Delta = 7;   mser_param.MinDiversity = 0.95;

[r,~] = vl_mser(I,'DarkOnBright',1, 'MaxArea', mser_param.MaxArea,...
     'MinArea', mser_param.MinArea, 'Delta', mser_param.Delta,...
    'MinDiversity', mser_param.MinDiversity); % applt MSER, get region seeds

M = zeros(size(I)) ;
for x=r'
     s = vl_erfill(I,x); % returns MEMBERS of the pixels which belongs to the extremal region
     M(s) = M(s) + 1; % M is binary image
end

figure(1); % plot 
subplot(2,1,1); imagesc(I) ; hold on ; axis equal off; colormap gray ;
[~,h]=contour(M,(0:max(M(:)))+.5) ;
set(h,'color','r','linewidth',2) ; % detected contours
subplot(2,1,2); imshow(M); % binary image



% 2. Create bubble template T(x,y) = Gaussian(gamma) * Circle(x,y | rho)

n = 5; % size of the patch

C = zeros(n,n); % the Circle
C_center = [x,y]; C_radius = rho;





% 3. Find the cross-correlation (or NCC?) between detected patch I(x,y) and T(x,y)


% 4. Optimised rho and gamma by minimizing(?) cross-correlation

