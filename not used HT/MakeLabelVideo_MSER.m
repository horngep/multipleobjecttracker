function [ output_args ] = MakeLabelVideo_MSER( glo_cmdout, bubStructList, BWList,vidNo )

% what we have: glo_smdout, bubStructList, BWList(list of Input Binary Images for each frame),
% video number
% output: labeled video saved 

% 1. DIMACS to MATRIX converter
%       Convert DIMACS glo_cmdout into 3 by N Matrix with only arcs that has
%       flow > 0
%       col1: <src>, col2: <dst>, col3: <flow>
%
% 2. Labeling bubbles
%
% 3. Create video with labels (this should be independent of preprocessing method)
% given: video number, BWList (obtained from vl_erfill in preprocessing)


%       1.1 remove everything but the flow list
k1 = strfind(glo_cmdout,'s');
fstart = k1(end) + 10;
glo_cmdout_temp = glo_cmdout(fstart:end);
k2 = strfind(glo_cmdout_temp,'p');
fend = k2(1) - 1;

glo_cmdout_final = glo_cmdout_temp(1:fend);

%       1.2 remove arcs with flow = 0 and convert to matrix format
f_location = strfind(glo_cmdout_final,'f');
flow_mat = []; index = 0;
s = size(f_location); s = s(2);
for row = 1:s

    flowi = str2num( glo_cmdout_final(f_location(row) + 17:f_location(row) + 27) );
    if flowi ~= 0
        index = index + 1;
        flow_mat(index,1) = str2num( glo_cmdout_final(f_location(row) + 1: f_location(row) + 8) ); % <src>
        flow_mat(index,2) = str2num( glo_cmdout_final(f_location(row) + 9: f_location(row) + 16) ); % <dst>
        flow_mat(index,3) = str2num( glo_cmdout_final(f_location(row) + 17:f_location(row) + 27) ); % <flow>        
    end        
end

%       1.3 remove flow columm
flow_mat(:,3) = [];




%       2.1 extract row that start with source node (src == 1) and put in
%       cell array.
%       cellArr = {[1,2] [1,4] [1,16] ...}
[noRow,~] = size(flow_mat);
cell_count = 0; cellArr = {};

for row = 1:noRow
    if flow_mat(row,1) == 1
        arr = flow_mat(row,:);
        cell_count = cell_count + 1;
        cellArr{cell_count} = arr;
        
    end
end


%       2.2 find the nodes belonging to the same bubble
%       cellArr = {[1,2,3,22,23,430] [1,4,5,32,33,98,99,430] ...}
for i = 1:cell_count % for every cell
    
    while(1)
        
        d = cellArr{i}(end); % take the last number of the cell

        src_row = flow_mat(:,1);
        dst_row = flow_mat(:,2);

        I = find(src_row == d); % find the index of src that matches it
        
        if isempty(I)
            break;  % if it is empty, break it and go to next cell
        end
        
        % otherwise, find the dst using the index
        k = dst_row(I);
        cellArr{i}(end+1) = k; % concat it to the array
                    
    end
    
end
cellArr;

%       2.3 Put labels to bubbles (if b.label = 0, then it is classify as false detection)

% for every cell in cellArr = {[1,2,3,22,23,430] [1,4,5,32,33,98,99,430] ...}
for bubNum = 1:length(cellArr)
    
    % for every element from the array (skip source and sink) [1,2,3,22,23,.....,430]
    for ele = 2:(length(cellArr{bubNum})-1) 
        
        % for every bubble k in bubStructListLabeled = {b1 b2 b3 b4}
        for k = 1:length(bubStructList)
               
            % if b.unode or b.vnode matches the element, put label bubNum onto the bubble
            if bubStructList{k}.unode == cellArr{bubNum}(ele) || bubStructList{k}.vnode == cellArr{bubNum}(ele)
                bubStructList{k}.label = bubNum;
            end
            
        end
        
    end   
    
end
bubStructList;


%       3.1 Create video and adding paths


% getting the frame rate of original video
addpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');
bubbleVideo1 = VideoReader('bubbleVideo1.avi');
rmpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');

% creating video
outputVideo = VideoWriter('testLabeledVid.avi'); % Video Name 
outputVideo.FrameRate = bubbleVideo1.FrameRate;
open(outputVideo)

% add path of where individual frames are 
vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath);



%       3.2 for each frame, fit Bounding box and Labels to the bubbles and
%       then save to video

for i = 1:2:128
     
    
    frameno = i;   
    I = imread(['Image' int2str(i)],'jpg');
    
    %       3.2.1 Bounding Boxs
    % Obtain Binary image associated to the frame from the BWList
    % frameno = 2k-1, k = index in BWList 
    k = double((frameno + 1)./2);
    BW = BWList{k}; % BW matrix for this frame

    % Get bounding box
    CC = bwconncomp(BW);
    s = regionprops(CC,'BoundingBox'); % s.BoundingBox = [x y w h]
    boxes = cat(1,s.BoundingBox);
    [boxRow,~] = size(boxes);


    %       3.2.2 Get Labels for the bubbles
    % get the bubbles that belong to the frame
    current_bub = {};
    for m = 1:length(bubStructList)
        if bubStructList{m}.frameno == frameno
            current_bub{end+1} = bubStructList{m};
        end
    end
    
    % get labeled array (Matching bubble struct with Boxes)
    labeled_array = zeros(1,length(boxRow));
    
    %}
    
    % for every boxes
    %   for every bubble in current_bub{}
    %       if both b.x and b.y is inside the box
    %           obtain b.label and put it into the labeled array
    
    for b = 1:boxRow
      
        % determine the ranges
        x_min = boxes(b,1);
        x_max = x_min + boxes(b,3); % x + w
        y_min = boxes(b,2);
        y_max = y_min + boxes(b,4); % y + h
            
        for c = 1:length(current_bub)
            
            b_x = current_bub{c}.x;
            b_y = current_bub{c}.y;
                                
            if (b_x >= x_min && b_x <= x_max && b_y >= y_min && b_y <= y_max)
                labeled_array(b) = current_bub{c}.label;
            end
            
        end
    end

    
    
    %       3.2.3 remove the rejected bubble (b.label == 0) and unmatched bubble 
    % (no box-label Match found) for both current_bub and boxes
    % [~,labEle] = size(labeled_array);
    %{ 
    % DOESNT WORK
    for q = 1:labEle
        if labeled_array(1,q) == 0
            labeled_array(1,q) = [];
            boxes(q,:) = [];
        end
    end
    %}
    
    %       3.2.4 insert annotation and Save image to video
    
    % insert annotation (box and label) to bubbles
    if (not(isempty(labeled_array)))
        J = insertObjectAnnotation(I,'rectangle',boxes,labeled_array,'TextBoxOpacity',0.9,'FontSize',18);
    else
        J = I;
    end
    img = figure; imshow(J);
    
    % save to video
    saveas(img,'FrameUsedToCreateVideo','jpg') % save the frame temporary
    ImgToBeWrittenToVid = imread('FrameUsedToCreateVideo.jpg');
    writeVideo(outputVideo,ImgToBeWrittenToVid); % write to video
    close(img) % close the figure
    delete FrameUsedToCreateVideo.jpg % delete the frame once written to video
    
    
    
end
 
    %      3.2.5 Close video and wrap up
 
 close(outputVideo) % close video
 rmpath(vidPath); % remove path where images are when done

end
