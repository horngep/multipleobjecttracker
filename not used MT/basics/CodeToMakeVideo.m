% http://www.mathworks.com/help/matlab/examples/convert-between-image-sequences-and-video.html

setup

% - Code for constructing video ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% getting the frame rate of original video
addpath('/Users/ihorng/Documents/MATLAB/Bubbles video');
bubbleVideo1 = VideoReader('bubbleVideo1.avi');
rmpath('/Users/ihorng/Documents/MATLAB/Bubbles video');

% creating video
outputVideo = VideoWriter('testVid.avi'); % Modify video name 
outputVideo.FrameRate = bubbleVideo1.FrameRate;
open(outputVideo)


% * Loop through the image sequence, load each image, and then write it to the video.
for i = 1:2:128
   I = imread(['ResultImage' int2str(i)],'jpg');
   writeVideo(outputVideo,I);
end
close(outputVideo)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



