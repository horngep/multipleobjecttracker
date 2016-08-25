function [ noBubArray_STMRB ] = PP_STMRB( mser_param, vidNo )
%   Preprocessing: Shift To Mean + Remove Background (frame 1)

% INPUT: mser_parameters struct, VideoNo
% OUTPUT:  noBub array



setup;


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

noBubArray_STMRB = zeros(1,64); % create number of bubbles matrix


% - Apply Mean Shift
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



     % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     % -- Remove Background

     % ~~~~ 2. check if the first image can be assume as background (ie no
     % bubbles)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     % Get background and hence Q
     if (i == 1) % get first image (assumed it is background)
         I1 = J;
     end

     maxIntensity = max(max(I1)); % get maximum intensity of backgrond
     M = zeros(size(I1));
     M(1:end, 1:end) = maxIntensity ; 

     Q = bsxfun(@minus,M,double(I1)); % Q = maximum intensity matrix - background intensity

     % -- Removing background
     J = bsxfun(@plus,double(J),Q);
     J = uint8(J);
     % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




     % - Apply MSER
     %{
     r = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.001, 'Delta', 5,...
        'MinDiversity', 0.95);  % get region seeds (parameters are now for vid 2)
    %}
     [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', mser_param.MaxArea,...
     'MinArea', mser_param.MinArea, 'Delta', mser_param.Delta,...
    'MinDiversity', mser_param.MinDiversity);  % get region seeds (parameters are now for vid 2)



     % - Get number of bubbles detected
     s = size(r);
     noBubArray_STMRB(k) = s(1);




     k = k+1;
 end
 
 
 


rmpath(vidPath); % remove path where images are when done

noBubArray_STMRB; % Output

end

