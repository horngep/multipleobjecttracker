% http://www.vlfeat.org/overview/mser.html

% -- Extracting MSER

% - Each MSERs can be identified uniquely by (at least) one of its 
% pixels x, as the connected component of the level set at level 
% I(x) which contains x. Such a pixel is called seed of the region.



% Read image 'spots.jpg' and convert to gray value.
pfx = fullfile(vl_root,'data','spots.jpg') ;

I = imread(pfx) ;
image(I) ;
I = uint8(rgb2gray(I)) ;


% - Fit ellipses using region seeds : this fits ellipsiods into region 
% seeds which represents approximation of where the regions are.

% Compute the Region seeds and the elliptical Frames
[r,f] = vl_mser(I,'MinDiversity',0.7,'MaxVariation',0.2,'Delta',10) ;
% Plot the region Frames
f = vl_ertr(f) ;
vl_plotframe(f) ;


% - Plotting MSER
M = zeros(size(I)) ;
for x=r'
 s = vl_erfill(I,x) ;
 M(s) = M(s) + 1;
end

figure(2) ;
clf ; imagesc(I) ; hold on ; axis equal off; colormap gray ;
[c,h]=contour(M,(0:max(M(:)))+.5) ;
set(h,'color','y','linewidth',3) ;
