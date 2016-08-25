% -- Applying MSER

% - Read image
I = imread('Image43','jpg');

% - Get region seeds
r = vl_mser(I,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.0005, 'Delta', 5,...
    'MinDiversity', 0.9)

%{
% * Apply histogram equalisation
I = histeq(I);
r = vl_mser(I,'DarkOnBright',1, 'MaxArea', 0.02, 'MinArea', 0.0005, 'Delta', 5,...
    'MinDiversity', 0.95);
%}

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
