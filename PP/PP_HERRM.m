function [ noBubArray_HERRM ] = PP_HERRM( mser_param, vidNo)
%   Preprocessing: Histogram Equalisation Remove Reverse Median

% INPUT: mser_parameters struct, VideoNo
% OUTPUT:  noBub array


% 1. Identify location of Bubble Frames
setup;
vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are

k = 1;
noBubArray_HERRM = zeros(1,64); % create number of bubbles matrix

for i = 1:2:128
     
 I = imread(['Image' int2str(i)],'jpg');
 I = histeq(I); % Histogram Equalisation
 
 % 2. Apply Remove Reverse Median for Row
 
 I = double(I);
 [noRow, noCol] = size(I);  % (341,476)
 
 
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
 
 
 % 3. Apply MSER
 [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', mser_param.MaxArea,...
     'MinArea', mser_param.MinArea, 'Delta', mser_param.Delta,...
    'MinDiversity', mser_param.MinDiversity);  % get region seeds (parameters are now for vid 2)

 % - Get number of bubbles detected
 s = size(r);
 noBubArray_HERRM(k) = s(1);
 

 k = k+1;
end


rmpath(vidPath); % remove path where images are when done
noBubArray_HERRM; % OUTPUT

end

