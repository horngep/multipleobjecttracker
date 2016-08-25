function [ noBubArray_RemBaseVid ] = PP_RemBaseVid( mser_param, vidNo )
%   Preprocessing: Removing Base Video

% INPUT: mser_parameters struct, VideoNo
% OUTPUT:  noBub array


setup;

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
noBubArray_RemBaseVid = zeros(1,64);

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
    %{
    [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, ...
        'MinArea', 0.001, 'Delta', 6,...
    'MinDiversity', 0.95);
    %}
    [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', mser_param.MaxArea,...
     'MinArea', mser_param.MinArea, 'Delta', mser_param.Delta,...
    'MinDiversity', mser_param.MinDiversity);
    s = size(r);
    noBubArray_RemBaseVid(k) = s(1);
    
    %{
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
    %}
    
    
k = k + 1;
end

% Algorithm1_Zhang(bubStructListRemBaseVid); % convert the list of bubble structs into DIMACS format
noBubArray_RemBaseVid;

end

