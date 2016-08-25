% Things to do before using this
% 1. select video number (it will automatically add and remove path)
% 2. adjust parameters for the video (using - Code for testing parameters)

setup;

% ~~~~~~~~~~~~~~~  1. Select video number ~~~~~~~~~~~~~~~~~~~~~~
vidNo = 2;

vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


k = 1;
noBubHistRRM = zeros(1,64); % create number of bubbles matrix

for i = 1:2:128
     
 I = imread(['Image' int2str(i)],'jpg');
 I = histeq(I); % Histogram Equalisation
 
 % - Apply Remove Reverse Median for Row
 I = double(I);
 s = size(I);  
 noRow = s(1); % get number of rows (341)
 noCol = s(2); % get number of columms (476)
 
 for j = 1:1:noRow
     
    row = I(j,:);                % get row j
    med = median(row);           % find median of row j
    revMed = 255 - med;          % reverse median 
    
    % remove Reverse Median from each element of row j
    for l = 1:1:noCol
        I(j,l) = I(j,l) + revMed; 
    end
 end
 
 J = uint8(I);
 
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 % - Apply MSER
 r = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.0005, 'Delta', 15,...
    'MinDiversity', 0.9);  % get region seeds (parameters are now for vid 2)
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 % - Get number of bubbles detected
 s = size(r);
 noBubHistRRM(k) = s(1);
 
 %{
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 % - Plotting MSER
 M = zeros(size(J)) ;
 
 for x=r'
     s = vl_erfill(J,x) ;
     M(s) = M(s) + 1;
 end

 sprintf('k is now %d',k)
 subplot(8,8,k); imagesc(J) ; hold on ; axis equal off; colormap gray ;
 [c,h]=contour(M,(0:max(M(:)))+.5) ;
 set(h,'color','r','linewidth',2) ;
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%}
 k = k+1;
end



%{
% ~~~~~~~~~~~~~~~~~ Code for testing parameters ~~~~~~~~~~~~~~~~~~~~~~

 I = imread('Image47.jpg');
 I = histeq(I);

% - Apply Remove Reverse Median for Row
 I = double(I);
 s = size(I);  
 noRow = s(1); % get number of rows (341)
 noCol = s(2); % get number of columms (476)
 
 for j = 1:1:noRow
     
    row = I(j,:);                % get row j
    med = median(row);     % find median of row j
    revMed = 255 - med;          % reverse median 
    
    % remove Reverse Median from each element of row j
    for l = 1:1:noCol
        I(j,l) = I(j,l) + revMed; 
    end
 end

 
% - Apply MSER
J = uint8(I);
% get region seeds
 r = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.0005, 'Delta', 15,...
    'MinDiversity', 0.9);

 % plotting MSER
 M = zeros(size(J)) ;
 
 for x=r'
     s = vl_erfill(J,x) ;
     M(s) = M(s) + 1;
 end

 figure(2) ;
 clf ; imagesc(J) ; hold on ; axis equal off; colormap gray ;
 [c,h]=contour(M,(0:max(M(:)))+.5) ;
 set(h,'color','r','linewidth',2) ;
 
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%}


rmpath(vidPath); % remove path where images are when done
clear i I j J k l med noCol noRow r revMed row s vidNo vidPath;
