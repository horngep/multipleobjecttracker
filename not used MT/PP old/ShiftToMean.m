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


noBubMeanShift = zeros(1,64); % create number of bubbles matrix

k = 1 ;

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
 
 
 % - Apply MSER
 
 % ~~~~~~~~~~~~~~~~~ 2. Set up Parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 r = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.001, 'Delta', 1,...
    'MinDiversity', 0.98);  % get region seeds

% - Get number of bubbles detected
 s = size(r);
 noBubMeanShift(k) = s(1);
 
 
 % ~~~~~~~~~~~~~~~~~ Code for Plotting MSER ~~~~~~~~~~~~~~~~~
%{
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
 %}
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 
 k = k+1;
 end

noBubMeanShift; % print no of bubbles


% ~~~~~~~~~~~~~~~~~ Code for testing suitable parameters ~~~~~~~~~~~~~~~~~
%{

I = imread('Image23','jpg');
 
 % - Shifting Image's grayscale towards AvgMean of all frames
 Id = double(I); 
 Av = mean2(Id);
 
 Diff = Av - AvgMean ;  % find the difference between mean of this frame and AvgMean

 D = zeros(size(I));
 D(1:end, 1:end) = Diff ; 

 J = bsxfun(@minus,Id,D);  % J = I - D  element wise (unit: both have to be double values)
 J = uint8(J); % convert back to unsigned int for showing images
 
 
 % - Apply MSER
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
 
%}
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




rmpath(vidPath); % remove path where images are when done
clear Av AvgMean D Diff i I Id J k r s sumOfMean vidNo vidPath noOfFrames ans;
