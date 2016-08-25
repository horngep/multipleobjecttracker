%
% Matlab commands to accompany the 2D Image and Signal Processing lab
%

% loading an image 
I = imread('basement00.tif');
imshow(I); colormap gray;

% rotating an image
J = imrotate(I,35,'bilinear');
imshow(J);

% picking out a subimage
imshow(I);      % re-display original image
subIm = imcrop; % select region using the mouse, double click to complete selection
imshow(subIm);

% displaying a histogram
subplot(1,2,1), imhist(I,128)
subplot(1,2,2), imshow(I)

% displaying a profile
fig2 = figure; % creates a new figure
subplot(1,2,1),imshow(I)
Improf = improfile; % use left mouse to initialise drawing line on image
                    % and middle button to signify end of line on image
subplot(1,2,2), plot(Improf) 

% surface plot of the intensity of a ROI
figure
imshow(I)
subIm = imcrop;
imshow(subIm);
J = double(subIm)/255; % convert to floating point format in range 0 to 1
mesh(J,'EdgeColor','red');
hidden off;            % turn off hidden line removal (make mesh transparent)
hold on; warp(J); hold off;

% Map the intensity distribution onto the surface.
warp(J,J);




% adding salt and pepper noise
J=imnoise(I,'salt & pepper');
imshow(J)

% 3x3 median filtering
K=medfilt2(J,[3 3]); 
figure;
imshow(K)

% 3x3 Gaussian filtering
h = fspecial('gaussian'); % default 3x3 filter (sigma=0.5)
h
L = filter2(h,J);
figure;
imagesc(L);               
colormap gray;

% Separable Gaussian filtering
gau_x = fspecial('gaussian',[1,20],2);
Igau_x = filter2( gau_x, I);
gau_y = fspecial('gaussian',[20,1],2);
IgauSep = filter2( gau_y, Igau_x );
imagesc(IgauSep); colormap gray;  % display result 

% Frequency domain Gaussian filtering
Ifft = fft2(I); % compute the 2D Fourier transform
gaufft = fft2(fspecial('gaussian',size(I),2));
IgauFou = fftshift(real(ifft2( gaufft .* Ifft )));
figure;
imagesc(IgauFou); colormap gray;

% Comparison of Spatial and Frequency domain methods
tic; gau_x = fspecial('gaussian',[1,6*sig+1],sig);
Igau_x = filter2( gau_x, I );
gau_y = fspecial('gaussian',[6*sig+1,1],sig);
IgauSep = filter2( gau_y, Igau_x ); toc

tic; Ifft = fft2(I);
gaufft = fft2(fspecial('gaussian',size(I),sig));
IgauFou = fftshift(real(ifft2( gaufft .* Ifft ))); toc





%
% Exercise 1: removing periodic background using FFT
% the following code is incomplete
%

I = imread('lunar1.tif');
imagesc(I);  colormap(gray);
Ifft = fftshift(fft2(I));
figure; colormap(gray);
imagesc(log(abs(Ifft) + 1)); 

[x,y] = ginput % Press enter to finish picking peaks

peaks = zeros(size(Ifft));
for i=1:size(x)
   % sets x,y, values to zero      
   peaks(round(y(i)),round(x(i))) = 1; 
end
Ifft(peaks == 1) = 0;
imagesc(log(abs(Ifft) + 1)); % look at modified fft

figure; colormap(gray);
imagesc(abs(ifft2(Ifft)));   % look at modified image

mask = [1 1 1 1 1]' * [1 1 1 1 1];
temp = filter2( mask, peaks);
Ifft(temp >= 1) = 0;

figure; colormap(gray);
imagesc(log(abs(Ifft) + 1)); % look at modified fft

figure; colormap(gray);
imagesc(abs(ifft2(Ifft)));   % look at modified image

%
% Automatic algorithm
% complete
%

I = imread('lunar1.tif');
figure
dim = size(I);

I_d = double(I) / 255; 
subplot(2,3,1); imshow(I_d);

% Compute a windowing function.
h = hanning(128);
h1 = [h(1:64) ; ones(dim(1)-128,1) ; h(65:128)];
h2 = [h(1:64) ; ones(dim(2)-128,1) ; h(65:128)];
hwind = h1*h2';

% Compute the FFT
spec = fftshift(fft2(I_d .* hwind));

% Compute the abs log spectrum
logsp = log(abs(spec));
subplot(2,3,2);
imagesc(logsp);

% Apply a Laplacian-of-Gaussian filter
K = fspecial('log',11,3);
fspec = -filter2(K,logsp,'same');
subplot(2,3,3);
imagesc(fspec);

% Threshold to find the peaks
sigma = std2(fspec);
thresh = fspec > 2.5*sigma;

% Make sure the central peak isn't zeroed
centre_x = floor(dim(2)/2);
centre_y = floor(dim(1)/2);
thresh(centre_y-10:centre_y+10, centre_x-10:centre_x+10) = 0;
subplot(2,3,4);
imagesc(thresh);

% Perform morphological erosion/dilation
thresh = bwmorph(thresh,'erode');
thresh = bwmorph(thresh,'dilate');
subplot(2,3,5);
imagesc(thresh);

% Zero the corresponding components in the FFT
spec(thresh == 1) = 0;

% Finally, inverse FFT
subplot(2,3,6);
imshow(abs(ifft2(spec)));



%
% Exercise 2: removing motion blur using a Wiener filter
% the following code is incomplete
%

bar = zeros(size(sub));
[sy,sx] = size(sub);
bar(round(sy/2), round(sx/2 + [-L/2:L/2]) ) = 1/L;
imagesc(bar); colormap gray;

barfft = fft2( bar );
Wfil = conj(barfft) ./ ( abs(barfft) .* abs(barfft) + K);

subfft = fft2(sub);
deblur = real(ifft2( subfft .* Wfil ));
imagesc(fftshift(deblur))  

K = ;
Wfil = conj(barfft) ./ ( abs(barfft) .* abs(barfft) + K);
deblur = real(ifft2( subfft .* Wfil ));
imagesc(fftshift(deblur))  


