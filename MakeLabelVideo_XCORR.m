function [ labeled_total_acc_bub_list ] = MakeLabelVideo_XCORR( glo_cmdout, total_acc_bub_list_n,vidNo )

% what we have: glo_smdout, bubStructList, video number
% output: labeled video saved 

% 1. DIMACS to MATRIX converter
%       Convert DIMACS glo_cmdout into 3 by N Matrix with only arcs that has
%       flow > 0
%       col1: <src>, col2: <dst>, col3: <flow>
%
% 2. Labeling bubbles
%
% 3. Create laebl video



% SECTION 1 : CONVERT glo_cmdout (DIMACS format) INTO MATRIX

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





% SECTION 2: LABELING BUBBLES (assign .label to each structs in bubStructList)

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

%       2.2 sort the cell array by the first unode (order of creation ? sort of) 
%           and put it to SortedCellArr

no_of_bub_created = length(cellArr);
append_arr = zeros(no_of_bub_created,2);
for c = 1:length(cellArr)
    tmp_arr = cellArr{c};
    append_arr(c,1) = tmp_arr(1);
    append_arr(c,2) = tmp_arr(2);
end
sorted_append_arr = sort(append_arr);
SortedCellArr = {};
for c = 1:length(append_arr)
    SortedCellArr{c} = sorted_append_arr(c,:);
end

%       2.3 find the nodes belonging to the same bubble including source,
%       sink, unodes and vnodes


%       SortedCellArr = {[1,2,3,22,23,430] [1,4,5,32,33,98,99,430] ...}
for i = 1:cell_count % for every cell
    
    while(1)
        
        d = SortedCellArr{i}(end); % take the last number of the cell

        src_row = flow_mat(:,1);
        dst_row = flow_mat(:,2);

        I = find(src_row == d); % find the index of src that matches it
        
        if isempty(I)
            break;  % if it is empty, break it and go to next cell
        end
        
        % otherwise, find the dst using the index
        k = dst_row(I);
        SortedCellArr{i}(end+1) = k; % concat it to the array
                    
    end
    
end
SortedCellArr;



%       2.4 Put labels to bubbles (but if b.label = 0, then it is classify as false detection)

% THERE IS A BUG
%for every cell in cellArr = {[1,2,3,22,23,430] [1,4,5,32,33,98,99,430] ...}
% for bubNum = 1:length(SortedCellArr)
%     
%     % for every element from the array (skip source and sink) [1,2,3,22,23,.....,430]
%     for ele = 2:(length(SortedCellArr{bubNum})-1) 
%         
%         % for every bubble k in bubStructListLabeled = {b1 b2 b3 b4}
%         for k = 1:length(bubStructList)
%             
%             b = bubStructList{k};
%             % if b.unode or b.vnode matches the element, put label bubNum onto the bubble
%             if b.unode == SortedCellArr{bubNum}(ele)
%                 bubStructList{k}.label = bubNum;
% %             elseif b.vnode == SortedCellArr{bubNum}(ele)
% %                 bubStructList{k}.label = bubNum;
%             end
%             
%         end
%         
%     end   
%     
% end

%for every cell in cellArr = {[1,2,3,22,23,430] [1,4,5,32,33,98,99,430] ...}
for i = 1:length(total_acc_bub_list_n)
    b = total_acc_bub_list_n{i};
    
    for j = 1:length(SortedCellArr)
        c = SortedCellArr{j};
        
        isThisBub = b.unode == c; % check if bubble b is in this sortedCellArr
        isThisBub = sum(isThisBub);
        
        if (isThisBub)
            b.label = j;
            total_acc_bub_list_n{i} = b;
        end
        
    end
    
end



% the resulting bubStructList now contained xcen, ycen, frameno, bub_patch,
% max_ncc_val, sigma, rho, unode, vnode, label

labeled_total_acc_bub_list = total_acc_bub_list_n; 










% SECTION 3 : CREATE LABELED VIDEO

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



%       3.2 for each frame ...

for i = 1:2:128
     
    I = imread(['Image' int2str(i)],'jpg');
    
    % find all bubbles in this frame
    bub_this_frame = {};
    for j = 1:length(total_acc_bub_list_n)
        if total_acc_bub_list_n{j}.frameno == i
            if total_acc_bub_list_n{j}.label ~= 0
                bub_this_frame{length(bub_this_frame)+1} = total_acc_bub_list_n{j};
            end
        end
    end
    
    % for each bubble in this frame, get centers, radius and labels
    nb = length(bub_this_frame);
    position = zeros(nb,3);
    labels = zeros(1,nb);
    
    for k = 1:length(bub_this_frame)
        position(k,1) = bub_this_frame{k}.xcen; % centers
        position(k,2) = bub_this_frame{k}.ycen;
        position(k,3) = bub_this_frame{k}.rho; % radius
        labels(1,k) = bub_this_frame{k}.label; % label
    end
    
    % insert annotation
    J = insertObjectAnnotation(I,'circle',position,labels,'LineWidth',2,'Color','red','TextColor','black');
    img = figure; imshow(J);    
    

    %       3.2.5 save to video
    saveas(img,'FrameUsedToCreateVideo','jpg') % save the frame temporary
    ImgToBeWrittenToVid = imread('FrameUsedToCreateVideo.jpg');
    writeVideo(outputVideo,ImgToBeWrittenToVid); % write to video
    close(img) % close the figure
    delete FrameUsedToCreateVideo.jpg % delete the frame once written to video

end
 


%      3.2.6 Close video and wrap up

close(outputVideo) % close video
rmpath(vidPath); % remove path where images are when done


 
 
 
 
end


