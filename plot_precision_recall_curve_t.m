function [ pr_labels,pr_scores ] = plot_precision_recall_curve_t( labeled_total_acc_bub_list,GT_t )
%PLOT_PRECISION_RECALL_CURVE_T Summary of this function goes here
%   Detailed explanation goes here

% PC curve for TRACKING only


% 1. Obtain tracks
len = length(labeled_total_acc_bub_list);

% 1.1 dummy array, will get the real useful one in 1.4
tracks_ = {};
tracks_label_ = []; % list of b.label associated with the element of tracks
count = 0;

% 1.2 get all tracks labels (including track with 1 bubbles)
for i = 1:len
    b = labeled_total_acc_bub_list{i};
    
    if b.label == 0 % skip non-bubbles

        continue;
    end
    
    contain_track_head = sum(tracks_label_ == b.label);
    if ~contain_track_head % if track doesnt already included
        tracks_label_(end+1) = b.label;
    end
end

% 1.3 get all tracks
for i = 1:length(tracks_label_)
    
    bub_in_this_track = {};
    for j = 1:len
        if labeled_total_acc_bub_list{j}.label == tracks_label_(i)
            bub_in_this_track{length(bub_in_this_track) + 1} = labeled_total_acc_bub_list{j};
        end
    end
    
    tracks_{i} = bub_in_this_track;
end

% 1.4 removes tracks (and tracks_label) with 1 bubbles (single detection) ?
tracks = {};
tracks_label = [];
for i = 1:length(tracks_)
    if length(tracks_{i}) ~= 1 % if no of bub in track is more than 1
        % put it into the input tracks
        tracks{end+1} = tracks_{i};
        tracks_label(end+1) = tracks_label_(i);
    end
end

% tracks and tracks_label are obtained


% WAIT !? What about false negative (left overs from GT_t) (ignores for a sec, 
% just like evaluation of detection,
% this will results in precision not reaching zero at the end, but stops at
% Random Precision instead (the red dash line on the graph))




% 2. Obtain 'scores' vector (decending order)

% 2.1 compute scores
% for simplicity, we stick with this first (see lab book: HT week6: Tracking Evaluation)
% scores = sum(Ea)/(no of bubbles in the tracks)
scores_ = zeros(1,length(tracks)); % dummy array, corresponding to tracks_label (non-decending order)

for i = 1:length(tracks)
    sum_Ea = 0;
    
    for j = 1:length(tracks{i})
        sum_Ea = sum_Ea + tracks{i}{j}.Ea;
    end

    scores_(i) = double(sum_Ea/length(tracks{i}));
end



% 2.2 sort tracks in decending orders of scores

% we only uses unode(col 1) to identify bubble and Ea(col 2) to sort them
a = zeros(length(tracks),2); % [tracks label, scores_]

for i = 1:length(tracks)
    a(i,1) = double(tracks_label(i));
    a(i,2) = double(scores_(i));
end

a_sorted = sortrows(a,2); % accending order
a_sorted = flipud(a_sorted); % decending order (what we want)


res = {}; % all the bubbles with sorted Ea
% assigning the tracks in decending order (acording to a_sorted)
for i = 1:length(tracks)
    track_label = a_sorted(i,1);
    
    for j = 1:length(tracks)
        t = tracks{j};
        if t{1}.label == track_label
            res{i} = t;
            break
        end
    end
end

pr_scores = a_sorted(:,2)'; % vl_pr()'s input

% results: res, tracks with decending order of 'scores', and scores
% associated
res; pr_scores; GT_t;

% we have 55 detected tracks
% but 38 GT tracks



% 3. Comparing results to GT_t to obtain 'labels'
% - check every res track against GT_t tracks
% - label +1 if the res{i} pass the criterian, else -1
% - the criterian is: if over 80% of res{i} overlap with any of the
% GT_t{j}, then it counts as correctly identified

pr_labels = zeros(1,length(res));
pr_labels(:,:) = -1;

GT_t_times_its_uses = zeros(1,length(GT_t));

for i = 1:length(res) % for every results tracks
    
    t_res = res{i};
    % determine the start and end frame
    % do some maths so we can calculate no of frames overlapping
    a_res = []; % array of frame no contains in this res track
    for l = t_res{1}.frameno:2:t_res{end}.frameno
        a_res(end+1) =l;
    end
    
    for j = 1:length(GT_t) % check against all GT_t
        t_gt = GT_t{j};
        a_gt = []; % array of frame no contains in this GT track
        for k = t_gt{1}.frameno:2:t_gt{end}.frameno
            a_gt(end+1) = k;
        end
        
        
        % check if enough of (e_res - s_res) lies within any places within
        % t_gt (say 80%)
        overlap_frames = []; % frameno that does overlap
        for m = 1:length(a_res)
            if sum(a_gt == a_res(m))
                overlap_frames(end+1) = a_res(m);
            end
        end
        overlap_frames;
        frame_overlap_percentage = double(length(overlap_frames)/length(a_res));
        
        % if yes, compute area overlaps
        if frame_overlap_percentage >= 0.5 % FRAME OVERLAP PERCENTILE <<<
            a_res; a_gt; % array of framenos
            t_res; t_gt; % tracks {[] [] [] ...}
            
            % find the total area of overlaps
            accumulated_overlap_area = 0;
            % compute area overlaps for all overlap bubbles
            for n = 1:length(overlap_frames)
                
                % identify which element of t_res and t_gt
                fno = overlap_frames(n); % the frame number
                element_res = find(a_res == fno); 
                element_gt = find(a_gt == fno);
                
                % these are the two bubbles that are the same frame
                b1 = t_res{element_res};
                b2 = t_gt{element_gt};
                
                % compute overlap
                del_x = abs(double(b1.xcen) - double(b2.xcen));
                del_y = abs(double(b1.ycen) - double(b2.ycen));
                patchSize_N = 101; % size of bub_patch

                if (del_x < patchSize_N) && (del_y < patchSize_N) % check if overlap 
                    % how much it overlap
                    overlap = double((patchSize_N - del_x)) * double((patchSize_N - del_y))/patchSize_N^2;
                else
                    overlap = 0; % did not overlap    
                end
                
                overlap_area_this_bub = double(overlap*101*101);
                accumulated_overlap_area = accumulated_overlap_area + overlap_area_this_bub;
                
            end
            
            % total area this track
            total_area_this_t_res = 101*101*length(t_res);
            
            % hence compute overall overlaping area percentile for the
            % track
            overlap_area_percent = double(accumulated_overlap_area/total_area_this_t_res);
            
            % AREA OVERLAP PERCENTILE <<<
            if overlap_area_percent >= 0.5
                pr_labels(i) = 1;
                GT_t_times_its_uses(j) = GT_t_times_its_uses(j) + 1;
            end
            
        end
        
    
    
    end

end

% calculate no_track misses
no_track_misses = sum(GT_t_times_its_uses == 0);

% 1.2 run vl_pr
figure(2);
vl_pr(pr_labels,pr_scores, 'NumPositives', sum(pr_labels>0) + no_track_misses);

% display some numbers
pr_labels_ = pr_labels'
pr_scores_ = pr_scores'
GT_t_times_its_uses_ = GT_t_times_its_uses'









end

