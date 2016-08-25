 
% -- Equalise histogram of all frames using histeq

k = 1;

for i = 1:2:128
     
 I = imread(['Image' int2str(i)],'jpg');
 
 I = histeq(I);
 
 subplot(8,8,k); imshow(I);
 k = k+1;
 end
