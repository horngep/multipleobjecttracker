% Things to do before using this
% 1. select video number (it will automatically add and remove path)
% 2. adjust parameters for the video (using - Code for testing parameters)

setup;

% ~~~~~~~~~~~~~~~~~ 1. Select video number ~~~~~~~~~~~~~~~~~
vidNo = 2;

vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are



% -- Shifting Image's grayscale towards AvgMean of all frames


% - Find AvgMean (avg gray level) of all frames within the video
noOfFrames = 0 ;
sumOfMean = 0 ;

 for i = 1:2:128
     
 I = imread(['Image' int2str(i)],'jpg');
 Id = double(I); 
 Av = mean2(Id);
 noOfFrames = noOfFrames + 1 ;
 sumOfMean = sumOfMean + Av ; 
 
 end
AvgMean = sumOfMean / noOfFrames ; % AvgMean of all frames

k = 1 ;
noBubMeanShiftRRM = zeros(1,64); % create number of bubbles matrix

 
 for i = 1:2:128
     
 I = imread(['Image' int2str(i)],'jpg');
 
 % - Shifting Image's grayscale towards AvgMean of all frames
 Id = double(I); 
 Av = mean2(Id);
 
 Diff = Av - AvgMean ;  % find the difference between mean of this frame and AvgMean

 D = zeros(size(I));
 D(1:end, 1:end) = Diff ; 

 J = bsxfun(@minus,Id,D);  % J = I - D  element wise (unit: both have to be double values)
 J = uint8(J); % convert back to unsigned int for showing images

 
 
 
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  % - Apply Remove Reverse Median for Row
 J = double(J);
 s = size(J);  
 noRow = s(1); % get number of rows (341)
 noCol = s(2); % get number of columms (476)
 
 for j = 1:1:noRow
     
    row = J(j,:);                % get row j
    med = median(row);     % find median of row j
    revMed = 255 - med;          % reverse median 
    
    % remove Reverse Median from each element of row j
    for l = 1:1:noCol
        J(j,l) = J(j,l) + revMed; 
    end
 end
  % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 
 
 % ~~~~~~~~~~~~~~~2. Adjust parameters ~~~~~~~~~~~~~~~~~~~~~~~
 % - Apply MSER
 J = uint8(J);
 r = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.05, 'MinArea', 0.0005, 'Delta', 1,...
    'MinDiversity', 0.9);  % get region seeds (parameters are now for vid 2)
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 % - Get number of bubbles detected
 s = size(r);
 noBubMeanShiftRRM(k) = s(1);
  
 
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 % - Plotting MSER
 M = zeros(size(J)) ;
 
 for x=r'
     b = vl_erfill(J,x) ;
     M(b) = M(b) + 1;
 end

 sprintf('k is now %d',k)
 subplot(8,8,k); imagesc(J) ; hold on ; axis equal off; colormap gray ;
 [c,h]=contour(M,(0:max(M(:)))+.5) ;
 set(h,'color','r','linewidth',2) ;
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 
 
 k = k+1;

 
 end

 
 
%{
% ~~~~~~~~~~~~~~~~~ Code for testing suitable parameters ~~~~~~~~~~~~~~~~~


I = imread('Image23','jpg');
 
 % - Shifting Image's grayscale towards AvgMean of all frames
 Id = double(I); 
 Av = mean2(Id);
 
 Diff = Av - AvgMean ;  % find the difference between mean of this frame and AvgMean

 D = zeros(size(I));
 D(1:end, 1:end) = Diff ; 

 J = bsxfun(@minus,Id,D);  % J = I - D  element wise (unit: both have to be double values)
 J = uint8(J); % convert back to unsigned int for showing images
 


 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  % - Apply Remove Reverse Median for Row
 J = double(J);
 s = size(J);  
 noRow = s(1); % get number of rows (341)
 noCol = s(2); % get number of columms (476)
 
 for j = 1:1:noRow
     
    row = J(j,:);                % get row j
    med = median(row);     % find median of row j
    revMed = 255 - med;          % reverse median 
    
    % remove Reverse Median from each element of row j
    for l = 1:1:noCol
        J(j,l) = J(j,l) + revMed; 
    end
 end
  % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


 % - Apply MSER
 J = uint8(J);
 r = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.001, 'Delta', 1,...
    'MinDiversity', 0.98)  % get region seeds

 % plotting MSER
 M = zeros(size(J)) ;
 
 for x=r'
     s = vl_erfill(J,x) ;
     M(s) = M(s) + 1;
 end

 figure(2); imagesc(J) ; hold on ; axis equal off; colormap gray ;
 [c,h]=contour(M,(0:max(M(:)))+.5) ;
 set(h,'color','r','linewidth',2) ;
 

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%}


rmpath(vidPath); % remove path where images are when done
clear Av AvgMean D Diff i I Id j J k l med noCol noOfFrames noRow r revMed row s ...
    sumOfMean vidNo vidPath;
