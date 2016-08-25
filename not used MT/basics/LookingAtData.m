
% -- Looking at video data

% Showing frames / histograms

k = 1;
imgNo = 1;
for i = 1:2:128
 I = imread(['Image' int2str(i)],'jpg');
 
 
 subplot(8,8,k);
 imshow(I);
 % histogram(I); 
 
  
 k = k + 1;
 end
 
 
