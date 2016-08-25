setup
vidNo = 2;

vidPath = '/Users/ihorng/Documents/MATLAB/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% testing the elipse obtain from mser
I = imread('Image77.jpg');
imshow(I);
[r,f] = vl_mser(I,'MinDiversity',0.9,'MaxVariation',0.9,'Delta',10, 'MinArea', 0.0005) ;
f = vl_ertr(f) ; % transpose f
vl_plotframe(f) ;




% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rmpath(vidPath); % remove path where images are when done
