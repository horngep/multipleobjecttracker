function [ noBubArray_STM ] = PP_STM( mser_param, vidNo )
%   Preprocessing: Shift To Mean

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


noBubArray_STM = zeros(1,64); % create number of bubbles matrix

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
    %{
    r = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.001, 'Delta', 1,...
    'MinDiversity', 0.98);  % get region seeds
    %}
    [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', mser_param.MaxArea,...
     'MinArea', mser_param.MinArea, 'Delta', mser_param.Delta,...
    'MinDiversity', mser_param.MinDiversity);  % get region seeds (parameters are now for vid 2)

    % - Get number of bubbles detected
    s = size(r);
    noBubArray_STM(k) = s(1);



    k = k+1;
end

noBubArray_STM; % print no of bubbles

rmpath(vidPath); % remove path where images are when done


end

