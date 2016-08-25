 vid=VideoReader('bubbleVideo6.avi');
 numFrames = vid.NumberOfFrames;
 n=numFrames;
 for i = 1:2:n
 frames = read(vid,i);
 imwrite(frames,['Image' int2str(i), '.jpg']);
 im(i)=image(frames);
 end
 