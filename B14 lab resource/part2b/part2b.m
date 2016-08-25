close all % close all figures
clear all % clear variables

ia = imread('keble_a.jpg');
ib = imread('keble_b.jpg');
ic = imread('keble_c.jpg');

% display images
figure(1); imshow(ib); hold on;
figure(2); imshow(ic); hold on;

% get points
figure(1); [xb,yb] = ginput
plot(xb,yb,'r+','markersize',7)  % marks selected points with a red cross

figure(2); [xc,yc] = ginput
plot(xc,yc,'r+','markersize',7)

Hbc = vgg_H_from_x_lin([xb, yb]', [xc,yc]')
vgg_gui_H(ib,ic,Hbc)

figure(4);
bbox=[-400 1200 -200 700]   % image space for mosaic
iwb = vgg_warp_H(ib, eye(3), 'linear', bbox);  % warp image b to mosaic image
imshow(iwb); axis image;
iwc = vgg_warp_H(ic, inv(Hbc), 'linear', bbox);  % warp image c to mosaic image
imshow(iwc); axis image;
imagesc(double(max(iwb,iwc))/255); % combine images into a common mosaic
axis image;


% display images
figure(1); imshow(ib); hold on;
figure(2); imshow(ia); hold on;

% get points
figure(1); [xb,yb] = ginput
plot(xb,yb,'r+','markersize',7)

figure(2); [xa,ya] = ginput
plot(xa,ya,'r+','markersize',7)

Hab = vgg_H_from_x_lin([xa, ya]', [xb,yb]')
vgg_gui_H(ia,ib,Hab)

iwa = vgg_warp_H(ia, Hab, 'linear', bbox);
figure(4);
imshow(iwa); axis image;

imagesc(double(max(iwa,max(iwb,iwc)))/255);
axis image;
