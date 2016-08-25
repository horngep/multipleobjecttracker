function [ pr_labels,pr_scores ] = plot_precision_recall_curve( labeled_total_acc_bub_list,GT )
%PLOT_PRECISION_RECALL_CURVE Summary of this function goes here

% PC curve for DETECTION only

% 0.1 removing bubbles with b.labels = 0; (decision = -1)(false negatives and true negatives)
ori_labeled_total_acc_bub_list = labeled_total_acc_bub_list;
labeled_total_acc_bub_list = {};
for i = 1:length(ori_labeled_total_acc_bub_list)
    b = ori_labeled_total_acc_bub_list{i};
    if ori_labeled_total_acc_bub_list{i}.label ~= 0
        labeled_total_acc_bub_list{end+1} = b;
    end
end

% 1.1 determining inputs ('pr_labels' and 'pr_scores')



% 1.1.1 getting sorted labeled_total_acc_bub_list to decending order of Ea score

len = length(labeled_total_acc_bub_list);

% we only uses unode(col 1) to identify bubble and Ea(col 2) to sort them
a = zeros(len,2); 

for i = 1:len
    b = labeled_total_acc_bub_list{i}; 
    a(i,1) = double(b.unode);
    a(i,2) = double(b.Ea);
end

a_sorted = sortrows(a,2); % accending order
a_sorted = flipud(a_sorted); % decending order (what we want)


res = {}; % all the bubbles with sorted Ea
for i = 1:len
    unode = a_sorted(i,1);
    
    for j = 1:len
        b = labeled_total_acc_bub_list{j};
        if b.unode == unode
            res{i} = b;
            break
        end
    end
end


% 1.1.2 asssigning pr_labels -1 or +1

% input: res; GT;
% for all the bubbles in res
for i = 1:len
    r = res{i};
    r.pr_label = -1; % if it is not assigned +1, then it is -1
    
    % which frame is this bub in
    ele = 0.5 * r.frameno + 0.5;
    bubs_this_frame = GT{ele};
    
    for j = 1:length(bubs_this_frame)
        b = bubs_this_frame{j};
        
        % COMPUTE OVERLAP BETWEEN r and b
        del_x = abs(double(r.xcen) - double(b.xcen));
        del_y = abs(double(r.ycen) - double(b.ycen));
        patchSize_N = 101; % size of bub_patch
        
        if (del_x < patchSize_N) && (del_y < patchSize_N) % check if overlap 
            % how much it overlap
            overlap = double((patchSize_N - del_x)) * double((patchSize_N - del_y))/patchSize_N^2;
        else
            overlap = 0; % did not overlap    
        end
        
        overlap_threshold = 0.55; % >> VARIABLE: overlapping threshold <<
        % reduce this to get better results tonight (18/04)
        
        if overlap > overlap_threshold
           if r.label ~= 0 % i.e. if we are not rejecting the bubbles
                r.pr_label = +1;

                % removing checked bubble from GT
                GT{ele}(j) = [];

                break;
           end
        end
       
        
    end
    
    res{i} = r;
end


% 1.1.3 getting vl_pr input
pr_labels = zeros(1,len);
pr_scores = zeros(1,len);

for i = 1:len
    pr_labels(1,i) = res{i}.pr_label;
    pr_scores(1,i) = res{i}.Ea;
end

% 1.1.4 how many bubbles are detected, how many misses ?
% note: no of bub in original GT was 390 (vid3)
no_bub_successfully_detected = sum(pr_labels == 1);
no_bub_misses = 0;
for i = 1:length(GT)
    no_bub_misses = no_bub_misses + length(GT{i});
end

% 1.2 run vl_pr
figure(1);
vl_pr(pr_labels,pr_scores, 'NumPositives', sum(pr_labels>0) + no_bub_misses);


% 2. Compute True Positives, Flase Postives, False Negatives and True
% negatives

tp = no_bub_successfully_detected
fn = no_bub_misses
false_detection = sum(pr_labels<0);
fp = false_detection

% THE ALGORITHM ASSUMES fp = sum(pr_labels<0)

end

