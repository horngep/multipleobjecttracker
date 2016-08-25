
% LABELING AND VISUALISING GT FOR DETECTION

vidNo = 3;
picPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
picPath = strcat(picPath,num2str(vidNo));
addpath(picPath);


% 1. HAND LABELING GROUND TRUTH

% GT = {};
% 
% count = 1;
% for i = 1:2:128
%     
%     
%     I = imread(['Image' num2str(i) '.jpg']); 
%     imshow(I); title(['frameno = ' num2str(i)]);
% 
%     % prompt request for number of bubbles
%     n = input(['enter number of bubbles in frame ' int2str(i) ' ']);
% 
%     % get the x,y locations from data cursor (ish)
%     [x,y] = ginput(n);
% 
%     % save data into desired structure
%     bub_this_frame = {};
%     for j = 1:length(x)
%         b = struct();
%         b.xcen = x(j);
%         b.ycen = y(j);
%         b.frameno = i;
%         bub_this_frame{j} = b;
%     end
%     GT{count} = bub_this_frame;
% 
% 
%     count = count + 1;
%     save(['GT_detection_' int2str(vidNo)]);
% end



    
% 
% % 2. LOOK AT GROUND TRUTH
% c = 1;
% for i = 1:2:128
% 
%     I = imread(['Image' num2str(i) '.jpg']); 
%     
%     bubs_this_frame = GT{c}; % {[1x1] [1x1] ...}
%     c = c+1;
%     
%     pos = zeros(length(bubs_this_frame),2);
%     for j = 1:length(bubs_this_frame)
%         b = bubs_this_frame{j};
%         pos(j,1) = b.xcen;
%         pos(j,2) = b.ycen;
%     end
%     % pos   = [120 248;195 246;195 312;120 312];
%     RGB = insertMarker(I, pos, '+', 'color', 'red', 'size', 5); 
% 
%     
%     imshow(RGB);
%     title(['frameno = ' num2str(i)]);
% 
% end



% Labeling Tracking GT


load('GT_detection_3_v2.mat'); % GT for tracking (GT = 390)

% Pre-label numbers to all GT bubbles
bubble_count = 0;
for i = 1:length(GT)
    for j = 1:length(GT{i})
        bubble_count = bubble_count + 1;
        GT{i}{j}.lab = bubble_count;
    end
end

% % look at bubbles and write down tracks
% c = 1;
% for i = 1:2:128
% 
%     I = imread(['Image' num2str(i) '.jpg']); 
%     if mod(c,2)
%         subplot(1,2,1); 
%     else
%         subplot(1,2,2)
%     end
%     
%     imshow(I);
%     
%     bubs_this_frame = GT{c}; % {[1x1] [1x1] ...}
%     c = c+1; 
%     
%     for j = 1:length(bubs_this_frame)
%         b = bubs_this_frame{j};
%         text(b.xcen,b.ycen,num2str(b.lab),'Color','red');
%     end
% 
%     
%     title(['frameno = ' num2str(i)]);
%     
%     ginput(1); % i.e. click to continue
% end


% hand labeling tracks
t1 = [1,2,3,4,5];
t2 = [6,12,20,27,34,41,47,53,58,64,70,77,84,90,98,105,112,118,124,132,140,148,156,164,169,174,179];
t3 = [11,19];
t4 = [7,15,23,30,37,43,49,55,59,65,72,79,85,93,100,107,114,120,126,134,142,150,158,166,171,176,181,...
    184,189,197,205,213,219,225,230,236,242,248,259,272,284,296,306,313,320,326,331,337,346,356,...
    366,376,384];
t5 = [8,16,24,31,38,44,51,56,61,67,74,81,87,95,102,109,115,121,127,135,143,151,159,167,172,177,182,185,...
    190,198,206,214,220,226,231,239,243,251,262,275,287,299,308,315,321,327,332,338,347,357,367,377,385];
t6 = [9,17,25,32,39,45,52,57,62,68,75,82,88,96,103,110,116,122,128,136,144,152,162];
t7 = [10,18,26,33,40,46];
t8 = [13,21,28,35,42,48,54];
t9 = [14,22,29,36];
t10 = [50];
t11 = [60,66,73,80,86,94,101,108];
t12 = [63,69,76,83,89,97,104,111,117,123,129,137,145,153,160];
t13 = [71,78,91,92,99,106,113,119,125,133,141,149,157,165,170,175,180];
t14 = [130,138,146,154,161];
t15 = [131,139,147,155,163,168,173,178,183,186,192,200,208];
t16 = [187,194,202,210,216,222,228,233,240,245,256,269,281,293,303,310,317,323,328,335,344,354,364,374,382,390];
t17 = [188,196,204,212,218,224];
t18 = [191,199,207];
t19 = [193,201,209,215,221,227];
t20 = [195,203,211,217,223,229,234];
t21 = [232,237,244,249,260,273,285,297,307,314];
t22 = [235,241,247,258,271,283,295,305,312,319,325,330,336,345,355,365,375,383];
t23 = [238];
t24 = [246,257,270,282,294,304,311,318,324,329];
t25 = [252,264,277,289,300];
t26 = [250,261,274,286,298];
t27 = [253,265,278,290];
t28 = [254,266,279,291,301];
t29 = [255,267,280,292,302];
t30 = [263,276,288];
t31 = [268];
t32 = [309,316,322];
t33 = [333,342,351,361,371,380,388];
t34 = [334,343,352,362,372,381,389];
t35 = [339,348,358,368];
t36 = [340,349,359,369,378,386];
t37 = [341,350,360,370,379,387];
t38 = [353,363,373];


tracks = {t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,...
    t19,t20,t21,t22,t23,t24,t25,t26,t27,t28,t29,t30,t31,t32,t33,t34,t35,t36,t37,t38};

% now we put bubbles into tracks
GT_t = {};
for i = 1:length(tracks) % 38
    t = {};
    for j = 1:length(tracks{i}) % element of each tracks
        
        % find bubble associated to j and put into t
        for k = 1:length(GT)
            for l = 1:length(GT{k})
                if GT{k}{l}.lab == tracks{i}(j);
                    t{end+1} = GT{k}{l};
                end
            end
        end
        
    end
    GT_t{i} = t;
end

GT_t;
% ohno = 0;
% % check if all bubbles in a track are in consecutive frame
% for i = 1:length(GT_t)
%     frames = [];
%     for j = 1:(length(GT_t{i})-1)
%         this = GT_t{i}{j}.frameno;
%         next = GT_t{i}{j+1}.frameno;
%         if this + 2 ~= next
%             ohno = ohno + 1;
%         end
%     end
% end
% % ohno = 0; hence all bubbles are in consecutive tracks


% rejects tracks with single bubble
GT_t;












