function [ glo_cmdout, total_acc_bub_list_n ] = XCORR_Algorithm1_LZhang( total_acc_bub_list,Wa,Ba,Wt,Bt )
% XCORR_ALGORITHM1_ZHANG Summary of this function goes here

% ________________________________________________________________________

% SECTION 1: CONVERT BUBSTRUCTLIST TO DIMACS FORMAT TEXT FILE

% This section construct the graph (network) from observation set
% bubStructList in DIMACS format and write into a text file.
%
% Algorithm 1 (L.Zhang 2008):
% - Construct the graph G(V,E,C,f) from observation set X
% - Start with empty flow


% INPUT: List (cell array) {} of Bubbles (struct) containing bubble
% information
% Bubble properties: b.frameno, b.x, b.y, b.unode, b.vnode

      
% Algorithm
% $ Forming source and sink node
% $ Extract Arcs (Edges) from the bubbles and number of Arcs
% $ Create and write a DIMACS file compatible for Goldberg's CS2


tic
%   Detailed explanation goes here

%   $ Basic information:
bubble_num = size(total_acc_bub_list); bubble_num = bubble_num(2);
nodes_num = bubble_num * 2 + 2; % each bub has 2 nodes + source, sink node
saved_file_name = 'DIMACS_format_input.txt';



%   $ Forming source and sink node
snode = 1; tnode = nodes_num;

%  
% %   $ Forming unode and vnode
% node_count = 2;
% for nn = 1:1:length(bubStructList)
%     b = bubStructList{nn};
%     
%     b.unode = node_count;
%     node_count = node_count + 1;
%     b.vnode = node_count;
%     node_count = node_count + 1;
%     
%     bubStructList{nn} = b;
% end

%   $ Extract Arcs (Edges) from the bubbles and number of Arcs
% Format: 'a <tail> <head> <cap l.b.> <cap u.b.> <cost>'


%  >>>>> Inter-Bubble Arcs
% 'a <bi.nodeid_u> <bi.nodeid_v> 0 1 <cost>';
total_acc_bub_list_n = {};

a1_str = '';
for i = 1:bubble_num
    in = 'inter-bubble arcs'
    
    % input bubStructList{i} > contains constrast, size, ncc etc
    % put into classifier Ea = Wx + B; that was pre-trained by SVM
    % output the cost of current inter-bubble arc
    
    
        
    % now we have w and b from BubbleExistanceClassifier
    % where Wa.X + Ba > 0 if y = +1 is correct bubble
    % and   Wa.X + Ba < 0 if y = -1 is not bubble (false detection)
    
    
    b = total_acc_bub_list{i};
    
    X = [double(b.avg_intensity);double(b.max_ncc_val)];   
    % X(1,1) = avg_intensity, X(2,1) = max_ncc_val
    
    Ea = dot(Wa,X) + Ba;
    
    % A. untuned
%     if Ea >= 0 % is correct bubble (WEIRD: COST SHOULD BE REVERSE)
%         cost = -1; % -10
%     else
%         cost = +1; % +10
%     end

    % B. tuned params
    if Ea < 0
        cost = +10000; % nd
    elseif Ea >= 0.5 % Ca
        cost = -20; % sd
    else
        cost = +2; % wd
    end
       
        
   
    % storing Ea, for the PR curve
    b.Ea = Ea;
    
    % AFLATION EXPERIMENTS: ALL DETECTED BUBBLE COUNTS (as we ignore graph)
    % cost = -100 all over
%     cost = -1;
%     b.Ea = 0;
%     
    
    
    total_acc_bub_list_n{i} = b;
    
    a1_str = strcat(a1_str, ['a ' int2str(total_acc_bub_list{i}.unode) ' '...
        int2str(total_acc_bub_list{i}.vnode) ' ' '0 ' '1 '...
        num2str(cost) '\n']); % this need to be trained using SVM
end
arcs_num = bubble_num;






% >>>>>  Source and Sink Arcs

% 'a <src.nodeid> <bi.nodeid_u> 0 1 <cost>';
% 'a <bi.nodeid_v> <dst.nodeid> 0 1 <cost>'

a2_str = '';
for i = 1:bubble_num
    
    % A. untuned source cost = 0
    % B. tuned source cost = +3 % ***
    % sink cost = 0;
    
    % Ablation,  cost = 0;
    a2_str = strcat(a2_str, ['a ' int2str(snode) ' ' int2str(total_acc_bub_list{i}.unode)...
        ' ' '0 ' '1 ' '3\n']); % source arc cost = 3 
    
    a2_str = strcat(a2_str,['a ' int2str(total_acc_bub_list{i}.vnode) ' ' int2str(tnode)...
        ' ' '0 ' '1 ' '0\n']); % sink arc cost = 0
end
arcs_num = arcs_num + bubble_num * 2;






% >>>>  Transitional Arcs

% 'a <bi.nodeid_v> <bk.nodeid_u> 0 1 <cost>';
a3_str = '';

% for every bubble
% for evey bubble after it 
% if the nextj_frame_no <= this_frame_no, do nothing
% else if nextj_frame_no = this_frmae_no + 2 (successive frame), create arc
% else if nextj_frame_no > this_frame_no + 2, break

% Obtaining relative size and overlap 
X = []; count = 1;
for i = 1:bubble_num-1
    for j = i+1:bubble_num
        iframe = total_acc_bub_list{i}.frameno;
        jframe = total_acc_bub_list{j}.frameno;
       if jframe <= iframe
            % do nothing
       elseif jframe == iframe + 2
            % compute overlap and relative rho
            this_b = total_acc_bub_list{i};
            next_b = total_acc_bub_list{j};
            
            % getting relative size, intensity
            rel_rho = abs(double(this_b.rho) - double(next_b.rho));
            rel_intensity = abs(double(this_b.avg_intensity) - double(next_b.avg_intensity));
            
            % getting overlap percentile
            del_x = abs(double(this_b.xcen) - double(next_b.xcen));
            del_y = abs(double(this_b.ycen) - double(next_b.ycen));
            patchSize_N = 101; % size of bub_patch
            if (del_x < patchSize_N) && (del_y < patchSize_N) % check if overlap 
                overlap = double((patchSize_N - del_x)*(patchSize_N - del_y)/patchSize_N^2);
            else
                overlap = 0; % did not overlap    
            end
       
            % getting all the data: PARAMTER OF CHOICE: overlap
            X(:,count) = [overlap; rel_rho];
            count = count+1;
            
       elseif jframe > iframe + 2
           break;
       end
    end
end
% Normalising data 
% X_ = bsxfun(@minus, X, mean(X,2)) ;
% X_ = bsxfun(@rdivide, X_, std(X_,[],2)) ;
% X = X_ ;


% MAIN PART
count = 1;
pos_count = 0;
neg_count = 1;
for i = 1:bubble_num-1
     
    in = ['transactational arcs bubble no.' num2str(i)]
    
    for j = i+1:bubble_num
        
        iframe = total_acc_bub_list{i}.frameno;
        jframe = total_acc_bub_list{j}.frameno;
        
       if jframe <= iframe
            % do nothing
            
       elseif jframe == iframe + 2
            
            % apply SVM and assigning cost
            X_this = X(:,count);
            count = count + 1;

            Et = dot(Wt,X_this) + Bt;
            
            % A. untuned
%             if Et >= 0 
%                 cost = -1; % -1
%                 pos_count = pos_count + 1;
%                 % cost == sink arc cost would not work
%             else
%                 cost = +1; % +10 
%                 neg_count = neg_count + 1;
%             end
            
            % B. tuned parameters
            if Et < 0
                cost = +10000; % nt
            elseif Et >= 1.25 % Ct
                cost = -20; % st
            else
                cost = +2; % wt
            end
       
            
            % DOING ABLATION EXPERIMENTS: switching off the transactional
            % arcs by assigning cost to infinite <<<<<<<<<<<<
%             cost = 10000;
            
            % create arc
            a3_str = strcat(a3_str, ['a ' int2str(total_acc_bub_list{i}.vnode) ' '... 
                                     int2str(total_acc_bub_list{j}.unode) ' ' '0 ' ...
                                     '1 ' int2str(cost) '\n']); % cost
                                 
            arcs_num = arcs_num + 1; % add arc counts
            
       elseif jframe > iframe + 2
            
           break;
           
       end
        
    end
    
 end

% concat arcs
a_str = strcat(a1_str, a2_str, a3_str);
 

 
%   $ Create a DIMACS file compatible for Goldberg's CS2
fileID = fopen(saved_file_name,'w+'); % 'w+' for wiped out old stuff (if any)

% formning the 'problem line' p 
% Format: 'p min <nodes_num> <arcs_num>'
p_str = ['p min ' int2str(nodes_num) ' ' int2str(arcs_num) '\n'];
% forming the 'node line' n  
% Format: 'n <node> <flow>'
n_str = '';
n_str = strcat(n_str, ['n ' int2str(snode) ' ' '0\n']);
n_str = strcat(n_str, ['n ' int2str(tnode) ' ' '-0\n']);
% Start with empty flow f(G) = 0, the iteration is done in SECTION 2 ***


% some comments add to the text
c1_str = ['c min flow problems with ' int2str(nodes_num) ' nodes and '...
    int2str(arcs_num) ' edges(arcs) \n'];
c2_str = 'c flow = f(G) , see paper \n';

% concat everything into a string with DIMACS format
dimacs_str = strcat(c1_str, p_str,c2_str, n_str, a_str);


% write to the text file
fprintf(fileID, dimacs_str);

% close file
fclose(fileID);

toc

% Results obtain: 
% a text file in DIMACS format associated to the list of bubbles 
% (bubbleStructlist). (file name indicated at saved_file_name) above

% SECTION 1 END
% ________________________________________________________________________



% SECTION 2: 

% This section run the while loop in Algorithm 1 (L.Zhang 2008): 
%
% WHILE (f(G) can be augmented)
%       - Augment f(G) by 1
%       - Find the min cost flow by Goldberg's CS2 algorithm
%       - IF (current min cost < global optimal cost)
%               Store current min-cost assignment as global optimum
% Return the global optimal flow as the best association hypothesis


f_G = 0; % flow to be augmented
global_optimal_cost = 100000000;
glo_cmdout = '';
min_cost_flow = 0; % number of flows associated to the global optimal cost

while(1)
    
    %   - Augment f(G) by 1
    
    [~, aug_cmdout] = system(['cat ' saved_file_name]);
    
    % find and replace 'n <snode> f_G' and 'n <tnode> f_G'  with 
    % 'n <snode> f_G' and 'n <tnode> f_G'
    text_to_find1 = ['n ' int2str(snode) ' ' int2str(f_G)];
    text_to_find2 = ['n ' int2str(tnode) ' ' '-' int2str(f_G)];

    f_G = f_G + 1; % increment flow f(G) by 1
    
    % replace the string
    text_to_replace1 = ['n ' int2str(snode) ' ' int2str(f_G)];
    text_to_replace2 = ['n ' int2str(tnode) ' ' '-' int2str(f_G)];
    
    aug_cmdout = strrep(aug_cmdout, text_to_find1, text_to_replace1);
    aug_cmdout = strrep(aug_cmdout, text_to_find2, text_to_replace2);
    
    % replace the text file
    fileID = fopen(saved_file_name,'w+');
    fprintf(fileID, aug_cmdout); fclose(fileID);
    
    
    
    
    
    %   - Check if f(G) can be augmented, i.e. if it produce error when run
    %   goldberg's algorithm
    
    [~, check_cmdout] = system(['cat ' saved_file_name ' | ./cs2']);

    % if contain 'Error2' then it can't
    found_error_string = strfind(check_cmdout, 'Error 2'); 
    if (size(found_error_string) > 0)
        break;
    end

    
    
    
    
    
    %   - Find the min cost flow using Goldberg's CS2 algorithm
    [~, min_cmdout] = system(['cat ' saved_file_name ' | ./cs2']);
    
    
    % obtain min cost
    current_min_cost = str2num(min_cmdout(269:284));  

    if (current_min_cost <= global_optimal_cost)

        % save both the min cost, the cmdout string and min cost flow
        global_optimal_cost = current_min_cost;
        glo_cmdout = min_cmdout;
        min_cost_flow = f_G;

    end   
end

% Result Obtained: 
% global optimal min cost, f(G) associated to it and
% the glo_cmdout string which represents all the information including the
% flow paths taken
glo_cmdout;
min_cost_flow;
global_optimal_cost;


% write the output to a file (didnt use this though)
fileID2 = fopen('DIMACS_format_output.txt','w+'); % 'w+' for wiped out old stuff (if any)
fprintf(fileID2, glo_cmdout);
fclose(fileID2);

toc

% SECTION 2 END
% ________________________________________________________________________
pos_count
neg_count
total_acc_bub_list_n;

end
