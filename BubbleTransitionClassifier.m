% Training SVM for transactional arcs Et

% DIRECT INPUT: this bubble {i} and next bubble {j}
% Et INPUT: relative position (delta_p), relative size (delta_s), relative
% contrast (delta_c), Overlap*
% where:
% overlap = 
% delta_p = mod({i}center - {j}center)
% delta_s = mod({i}rho - {j}rho)
% delta_c = mod({i}avg_intensity - {j}intensity)

% X = [delta_p; delta_s]; % only account first two parameters
% Wt.X + Bt > 0 then is the same bubble (set cost to be -ive)



% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1. Extract data need for training
% training frames: {i}[25,45,71,85,105,117] (5 pairs)
%                  {j}[27,47,73,87,107,119]
load('Et_training_data.mat');
total_acc_bub_list_training;
for i = 1:length(total_acc_bub_list_training)
    b = total_acc_bub_list_training{i};
    b.prevunode = 0;
    total_acc_bub_list_training{i} = b;
end

training_data_i = {}; % cell of cells = {{bubbles in frame 25} {bubbles in frame 45}..}
training_data_j = {}; % cell of cells = {{bubbles in frame 27} {bubbles in frame 47}..}

training_frames_i = [25,45,71,85,105,117];
training_frames_j = [27,47,73,87,107,119];

% getting all the bubbles for frames in training data
for t = 1:length(training_frames_i)
    bub_this_frame = {};
    for s = 1:length(total_acc_bub_list_training)
        b = total_acc_bub_list_training{s};
        if b.frameno == training_frames_i(t)
            bub_this_frame{length(bub_this_frame)+1} = b;
        end
    end
    training_data_i{t} = bub_this_frame;
end

for t = 1:length(training_frames_j)
    bub_this_frame = {};
    for s = 1:length(total_acc_bub_list_training)
        b = total_acc_bub_list_training{s};
        if b.frameno == training_frames_j(t)
            bub_this_frame{length(bub_this_frame)+1} = b;
        end
    end
    training_data_j{t} = bub_this_frame;
end

% result: cell of cells of bubbles contain in frames selected for training
training_data_i; % {{bubbles in frame 25} {bubbles in frame 45} {} {}...}
training_data_j;





% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2. Hand labeling training data

% -- need a way of identify bubbles (can use unode)
% -- might means need to draw circles and display unode

% -- also need a way to identify pair. i.e. these two are the same bub 
% we can use b.frontunode, and insert unode of the linked
% bubble
% -- think about what we want to put into SVM
% we want (Y) label +1 (true) if the bubble are linked, else -1
% X = [delta_p; delta_s]; % relative position and relative size



% 2.1 visualise (only need 1 time) and hand label pairs of detected bubbles that is
% the same true bubble
% add path of where individual frames are 
% vidNo = 2;
% picPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
% picPath = strcat(picPath,num2str(vidNo));
% addpath(picPath);
% 
% % 2.1.1 Identify frame
% I1 = imread('Image117.jpg'); 
% I2 = imread('Image119.jpg');
% bub_frame_i = training_data_i{6};
% bub_frame_j = training_data_j{6};
% 
% % 2.1.2 This frame annotate
% % for each bubble in this frame, get centers, radius and labels
% nb = length(bub_frame_i);
% position = zeros(nb,3);
% labels = zeros(1,nb);
% 
% for k = 1:length(bub_frame_i)
%     position(k,1) = bub_frame_i{k}.xcen; % centers
%     position(k,2) = bub_frame_i{k}.ycen;
%     position(k,3) = bub_frame_i{k}.rho; % radius
%     labels(1,k) = bub_frame_i{k}.unode; % unode
% end
% 
% % insert annotation
% J = insertObjectAnnotation(I1,'circle',position,labels,'LineWidth',2,...
%     'Color','red','TextBoxOpacity',0.2,'TextColor','black');
% % subplot(1,2,1); imshow(J);  
% 
% 
% % 2.1.3 Next frame annotate
% nb = length(bub_frame_j);
% position = zeros(nb,3);
% labels = zeros(1,nb);
% 
% for k = 1:length(bub_frame_j)
%     position(k,1) = bub_frame_j{k}.xcen; % centers
%     position(k,2) = bub_frame_j{k}.ycen;
%     position(k,3) = bub_frame_j{k}.rho; % radius
%     labels(1,k) = bub_frame_j{k}.unode; % unode
% end
% 
% % insert annotation
% J = insertObjectAnnotation(I2,'circle',position,labels,'LineWidth',2,...
%     'Color','red','TextBoxOpacity',0.2,'TextColor','black');
% % subplot(1,2,2);imshow(J); 


% 2.2 Hand labeling
% list of unodes pair
% frame 25,27 > [unode in first frame, unode in second frame that are the
% same bubble; ...];
h_25_27 = [436,464; 438,468; 448,472; 452,476; 462,484];
h_45_47 = [718,744; 720,764; 724,750; 732,756; 734,758; 738,762; 740,766];
h_71_73 = [1134,1176; 1136,1178; 1146,1188; 1150,1190; 1172,1212];
h_85_87 = [1414,1444; 1416,1448; 1424,1458; 1426,1460; 1432,1468; 1442,1480];
h_105_107 = [1868,1926; 1886,1936; 1896,1950];
h_117_119 = [2244,2326; 2258,2340; 2270,2352; 2314,2388];
hand_label_sets = {h_25_27, h_45_47, h_71_73,h_85_87,h_105_107,h_117_119};


% 2.2.1 put data into bubble struct
for i = 1:length(training_data_j)
    train_ = training_data_j{i};
    hand_ = hand_label_sets{i};
    
    for j = 1:length(train_)
        b = train_{j};
        for k = 1:length(hand_)
            search_unode = hand_(k,2);
            if b.unode == search_unode;
                b.prevunode = hand_(k,1);
                training_data_j{i}{j} = b;
            end
        end
    end
end

% i = 15,12,20,15,30,41 = 133 bubbles total
% j = 11,14,21,19,28,38 = 131 bubbles total
% total of 3436 training data


% 3. Train SVM
% variables: relative size(radius), overlap
% X = [relative rho; overlap]

% 3.0.1 getting total length of data needed to be labeled
len = 0;
for a = 1:length(training_data_i)
    for i = 1:length(training_data_i{a})
        for j = 1:length(training_data_j{a})
            len = len + 1;
        end
    end
end

% 3.0.2 create SVM training array
X = zeros(2,len); 
Y = zeros(1,len);



% 3.1 Getting training data for SVM
count = 0; 
% overlap_count = 1; delta = zeros(6,1);
for a = 1:length(training_data_i) % getting frame pairs
    for i = 1:length(training_data_i{a})
        this_b = training_data_i{a}{i}; % this bubble
        for j = 1:length(training_data_j{a})
            next_b = training_data_j{a}{j}; % next bubble
            
            % 3.1.1 getting relative size, intensity
            rel_rho = abs(double(this_b.rho) - double(next_b.rho));
            rel_intensity = abs(double(this_b.avg_intensity) - double(next_b.avg_intensity));
            
            % 3.1.2 getting overlap percentile
            del_x = abs(double(this_b.xcen) - double(next_b.xcen));
            del_y = abs(double(this_b.ycen) - double(next_b.ycen));
            patchSize_N = 101; % size of bub_patch

%             if (del_x < patchSize_N) && (del_y < patchSize_N)
%                 delta(:,overlap_count) = [del_x; del_y; this_b.xcen; next_b.xcen; this_b.ycen; next_b.ycen];
%                 overlap_count = overlap_count + 1;
%             end
            
            if (del_x < patchSize_N) && (del_y < patchSize_N) % check if overlap 
                % how much it overlap
                overlap = double((patchSize_N - del_x)) * double((patchSize_N - del_y))/patchSize_N^2;
            else
                overlap = 0; % did not overlap    
            end
            
            
            % 3.1.3 determining label Y (-1 or +1
            % if next bubble's previous unode is this bubble's unode (i.e. they are the same bubble)
            if next_b.prevunode == this_b.unode 
                train_label = 1;
            else  
                train_label = -1;
            end
            
            % 3.1.4 putting data into arrays for training SVM 
            count = count + 1;
            X(1,count) = overlap;
            X(2,count) = rel_rho; 
            %X(3,count) = rel_intensity;
            Y(1,count) = train_label;
            
        end
    end
end

% normalised
% X_ = bsxfun(@minus, X, mean(X,2)) ;
% X_ = bsxfun(@rdivide, X_, std(X_,[],2)) ;
% X = X_ ;

% 3.2 Visualise data
Xp = X(:,Y==1);
Xn = X(:,Y==-1);

figure;
plot(Xn(1,:),Xn(2,:),'*r');
%scatter3(Xn(1,:),Xn(2,:),Xn(3,:),'*r')
%plot(Xn,'*r');
hold on
plot(Xp(1,:),Xp(2,:),'*b');
%scatter3(Xp(1,:),Xp(2,:),Xp(3,:),'*b')
%plot(Xp,'*b');


axis normal;

% 3.4 train SVM using vl_feat's function - output: Wt and Bt
% lambda = 0.0000001 ; % Regularization parameter
% maxIter = 100000000 ; % Maximum number of iterations
lambda = 0.0001;
maxIter = 100000;

[Wt Bt info] = vl_svmtrain(X, Y, lambda, 'MaxNumIterations', maxIter, 'epsilon', 1e-5, 'verbose', ...
    'weights', (Y+1)+0.01);

% plot line
eq = [num2str(Wt(1)) '*x+' num2str(Wt(2)) '*y+' num2str(Bt)];
line = ezplot(eq, [0 1 -20 1]);
set(line, 'Color', [0 0.8 0],'linewidth', 2);
xlabel('relative radius'); 
ylabel('overlap');
axis normal;

% plot line 1D
% eq = [num2str(Wt) '*x+' num2str(Bt)];
% line = ezplot(eq, [0 3000 0 1]);
% set(line, 'Color', [0 0.8 0],'linewidth', 2);
% %refline(Wt,Bt);
% axis normal


% % TODO: 
Wt % lets try this first then
Bt % if the output more than 0, then uncertain

% % look at the results if applied Wt and Bt to the original data set
Xn; 
res_n = zeros(1,length(Xn));
for i = 1:length(res_n)
    res_n(1,i) = dot(Wt,Xn(:,i)) + Bt;
end
res_n = sort(res_n);

Xp; 
res_p = zeros(1,length(Xp));
for i = 1:length(res_p)
    res_p(1,i) = dot(Wt,Xp(:,i)) + Bt;
end
res_p = sort(res_p);

figure(2); plot(res_n,'r*');
%figure(3); 
hold on
plot(res_p,'b*');


