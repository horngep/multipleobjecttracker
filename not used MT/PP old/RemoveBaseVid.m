setup;

vidNo = 2; % ACTION: Select video number


% Creating video
addpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');
bubbleVideo1 = VideoReader('bubbleVideo1.avi');
rmpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');

outputVideo = VideoWriter('testVid.avi'); % Video Name 
outputVideo.FrameRate = bubbleVideo1.FrameRate;
open(outputVideo)

% -- Main code
k = 1;
bub_struct_count = 0;
node_count = 2;


for i = 1:2:128

    % Base Video (Bubble video 1)
    addpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage1');
    
    vid_base_frame = imread(['Image' int2str(i)],'jpg');

    rmpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage1'); 

    
    % Target Video
    vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
    vidPath = strcat(vidPath,num2str(vidNo));
    addpath(vidPath); 
    
    vid_tar_frame = imread(['Image' int2str(i)],'jpg');
    
    rmpath(vidPath); 

    
    % Take out the reverese base frame
    max_intensity_matrix = zeros(size(vid_base_frame));
    max_intensity_matrix(:,:) = 255 ;
    rev_vid_base_frame = bsxfun(@minus,max_intensity_matrix,double(vid_base_frame));
    
    J = bsxfun(@plus,double(vid_tar_frame),double(rev_vid_base_frame));
  
    
    % Amplify bubble depth
    for i = 1:numel(J)
        if (J(i) < 255)
            J(i) = J(i) - 2 * (255 - J(i));
        end
    end
    J = uint8(J);
    
    
    % apply MSER
    [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.001, 'Delta', 6,...
    'MinDiversity', 0.95);

    % plot MSER
    M = zeros(size(J)) ;

    for x=r'
        s = vl_erfill(J,x) ;
        M(s) = M(s) + 1;
    end
    
    %{
    subplot(8,8,k); 
    imagesc(J) ; hold on ; axis equal off; colormap gray ;
    [c,h]=contour(M,(0:max(M(:)))+.5) ;
    set(h,'color','r','linewidth',2) ;
    k = k + 1;
    %}
    
    %{
     % Write to video
     img = figure(1); % this is for video

     imagesc(J) ; hold on ; axis equal off; colormap gray ;
     [c,h]=contour(M,(0:max(M(:)))+.5) ;
     set(h,'color','r','linewidth',2) ;

     saveas(img,'FrameUsedToCreateVideo','jpg') % save the frame temporary, delete it once used
     ImgToBeWrittenToVid = imread('FrameUsedToCreateVideo.jpg');
     writeVideo(outputVideo,ImgToBeWrittenToVid); 
     close(img) 
     delete FrameUsedToCreateVideo.jpg
    %}
    
     % Get Bub Struct List
      noOfBubCurrentFrame = size(f);
      noOfBubCurrentFrame = noOfBubCurrentFrame(2); % columm is the number of bubbles

      for i = 1:noOfBubCurrentFrame

          % create bubble structure
          bub_struct_count = bub_struct_count + 1;
          b = struct(); b.frameno = 2*k - 1;
          b.x = f(1,i); b.y = f(2,i);
          b.unode = node_count; node_count = node_count + 1;
          b.vnode = node_count; node_count = node_count + 1;

          bubStructListRemBaseVid{bub_struct_count} = b;

      end
    

end

Algorithm1_Zhang(bubStructListRemBaseVid); % convert the list of bubble structs into DIMACS format

close(outputVideo) % close video