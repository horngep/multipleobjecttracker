% Things to do before using this
% 1. select video number (it will automatically add and remove path)
% 2. check if assumtion is true
% 3. adjust parameters for the video, set parameters 

setup;

% ~~~~~~~~~~~~~~~  1. Select video number ~~~~~~~~~~~~~~~~~~~~~~
vidNo = 2;

vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



% -- Apply histogram equalisation then remove background



% - Get background, and hence Q
% ~~~~~~~~~~~~~~~~~ 2. Check if assumtion is true ~~~~~~~~~~~~~~~~~
% Assume frame 1 has no bubbles and let it be background
F = imread('Image1','jpg');

F = histeq(F); % histogram equalisation
maxIntensity = max(max(F)); % get maximum intensity of backgrond
M = zeros(size(F));
M(1:end, 1:end) = maxIntensity ; 

Q = bsxfun(@minus,M,double(F)); % Q = maximum intensity matrix - background intensity


noBubHistRB = zeros(1,64); % create number of bubbles matrix




% ~~~~ Code for making Video ~~~~~~~~~~~~~~~~~~@@@@@@@@@@@@@@@@@@@@@@
% getting the frame rate of original video
addpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');
bubbleVideo1 = VideoReader('bubbleVideo1.avi');
rmpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');

% creating video
outputVideo = VideoWriter('testVid.avi'); % Video Name 
outputVideo.FrameRate = bubbleVideo1.FrameRate;
open(outputVideo)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~@@@@@@@@@@@@@@@@@@@@@@


k = 1; % iterator; where Frame Number = 2k-1
node_count = 2;
bub_struct_count = 0;
BWList = {}; % use in makeLabeledVideo.m
for i = 1:2:128
     
 I = imread(['Image' int2str(i)],'jpg');
 I = histeq(I); % histogram equalisation
 
 % -- Removing background
 J = bsxfun(@plus,double(I),Q);
 J = uint8(J);
 
 

 
 % - Apply MSER
 %~~~~~~~~~~~~~~~~~~~~~~~ 3. Set up Parameters ~~~~~~~~~~~~~~~~~~~~~~~
    %{
 [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.001, 'Delta', 10,...
    'MinDiversity', 0.95);  % get region seeds (parameters are now for vid 2)
 %}
 [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.0005, 'Delta', 6,...
    'MinDiversity', 0.92);  % get region seeds (parameters are now for vid 2)
  f = vl_ertr(f) ;

 % this is for makeLabeledVideo.m +++++++++++++++++++++++++++++++++++++++++++++++++++++
 % MEMBERS=VL_ERFILL(I,ER) returns the list MEMBERS of the pixels which belongs to the extremal region represented by the pixel ER.
 M = zeros(size(J)) ;
 for x=r'
     s = vl_erfill(J,x) ;
     M(s) = M(s) + 1; % M is binary input image
 end
 
 BWList{k} = M; % List of Binary Input Images (BW) (for regionprops()) ++++++++++++
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 
 % - Get number of bubbles detected
 s = size(r);
 noBubHistRB(k) = s(1);
 
 
 % ~~~~~~~~~~~~~~~~~ Code for Plotting MSER ~~~~~~~~~~~~~~~~~~~
 % - plotting MSER
 M = zeros(size(J)) ;
 
 for x=r'
     s = vl_erfill(J,x) ;
     M(s) = M(s) + 1;
 end

 sprintf('k is now %d',k)
 subplot(8,8,k);
 
 %{
 % ~~~~ Code for making Video ~~~~~~~~~~~~~~~~~@@@@@@@@@@@@@@@@@@@@@@
 img = figure(1); % this is for video
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~@@@@@@@@@@@@@@@@@@@@@@
 %}
 
 imagesc(J) ; hold on ; axis equal off; colormap gray ;
 [c,h]=contour(M,(0:max(M(:)))+.5) ;
 set(h,'color','r','linewidth',2) ;
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
 
 %{
 % ~~~~ Code for making Video ~~~~~~~~~~~~~~~~~@@@@@@@@@@@@@@@@@@@@@@
 % writing it to video file
 saveas(img,'FrameUsedToCreateVideo','jpg') % save the frame temporary
 ImgToBeWrittenToVid = imread('FrameUsedToCreateVideo.jpg');
 writeVideo(outputVideo,ImgToBeWrittenToVid); % write to video
 close(img) % close the figure
 delete FrameUsedToCreateVideo.jpg % delete the frame once written to video
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~@@@@@@@@@@@@@@@@@@@@@@
%}
 
 % -- Obtain information for Constructing Graphs/Network using < Struct >~~~~~$$$$$$$$$$$
  noOfBubCurrentFrame = size(f);
  noOfBubCurrentFrame = noOfBubCurrentFrame(2); % columm is the number of bubbles
 
  for i = 1:noOfBubCurrentFrame
      
      % create bubble structure
      bub_struct_count = bub_struct_count + 1;
      b = struct(); b.frameno = 2*k - 1;
      b.x = f(1,i); b.y = f(2,i); 
      b.unode = node_count; node_count = node_count + 1;
      b.vnode = node_count; node_count = node_count + 1;
      b.label = 0; % default label value, this will be modified in makeLabeledVideo.m
      
      bubStructListHistRB{bub_struct_count} = b;
      
  end
 
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$$$$$$$$$$$
 
 
 
 k = k+1;   
end
 bubStructListHistRB;
 

% Results
close(outputVideo) % close video ~~~~~~~~~~~~~~~~~~~~~~~@@@@@@@@@@@@@@@@
noBubHistRB; % print no of bubbles

% -- Apply L.Zhang's algorithm
% glo_cmdout = Algorithm1_Zhang(bubStructListHistRB); % Obtained optimal flow

% -- Construct labeled video ++++++++++++++++++++++++++++++++++++++
% makeLabeledVideo(glo_cmdout,bubStructListHistRB,BWList,vidNo);



rmpath(vidPath); % remove path where images are when done
clear ans F i I j k M maxIntensity Q r s vidNo vidPath noOfBubCurrentFrame newCell J f...
     b;
