% Function called in this script: Preprocess_HistEqRB()



setup;

% ACTION: Choosing video number
vidNo = 2;

% add path
vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath);


% Apply preprocessing
bubStructListHistRB = Preprocess_HisEqRB_MSER();

Algorithm1_Zhang( bubStructListHistRB );




rmpath(vidPath);
