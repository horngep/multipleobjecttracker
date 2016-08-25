function [ glo_cmdout ] = Algorithm1_Zhang( bubStructList )
% ALGORITHM1_ZHANG Summary of this function goes here

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
bubble_num = size(bubStructList); bubble_num = bubble_num(2);
nodes_num = bubble_num * 2 + 2; % each bub has 2 nodes + source, sink node
saved_file_name = 'DIMACS_format_input.txt';



%   $ Forming source and sink node
snode = 1; tnode = nodes_num;

 
%   $ Forming unode and vnode
node_count = 2;
for nn = 1:1:length(bubStructList)
    b = bubStructList{nn};
    
    b.unode = node_count;
    node_count = node_count + 1;
    b.vnode = node_count;
    node_count = node_count + 1;
    
    bubStructList{nn} = b;
end

%   $ Extract Arcs (Edges) from the bubbles and number of Arcs
% Format: 'a <tail> <head> <cap l.b.> <cap u.b.> <cost>'


%   Inter-Bubble Arcs
% 'a <bi.nodeid_u> <bi.nodeid_v> 0 1 <cost>';

a1_str = '';
for i = 1:bubble_num
    a1_str = strcat(a1_str, ['a ' int2str(bubStructList{i}.unode) ' '...
        int2str(bubStructList{i}.vnode) ' ' '0 ' '1 '...
        '-9.44\n']); % this need to be trained using SVM
end
arcs_num = bubble_num;

%   Source and Sink Arcs
% 'a <src.nodeid> <bi.nodeid_u> 0 1 <cost>';
% 'a <bi.nodeid_v> <dst.nodeid> 0 1 <cost>'
a2_str = '';
for i = 1:bubble_num
    a2_str = strcat(a2_str, ['a ' int2str(snode) ' ' int2str(bubStructList{i}.unode)...
        ' ' '0 ' '1 ' '0\n']); % source arc cost = 0 for now
    a2_str = strcat(a2_str,['a ' int2str(bubStructList{i}.vnode) ' ' int2str(tnode)...
        ' ' '0 ' '1 ' '0\n']); % sink arc cost = 0 for now
end
arcs_num = arcs_num + bubble_num * 2;

%   Transitional Arcs
% 'a <bi.nodeid_v> <bk.nodeid_u> 0 1 <cost>';
a3_str = '';

% for every bubble
% for evey bubble after it 
% if the nextj_frame_no <= this_frame_no, do nothing
% else if nextj_frame_no = this_frmae_no + 2 (successive frame), create arc
% else if nextj_frame_no > this_frame_no + 2, break

for i = 1:bubble_num-1
     
    for j = i+1:bubble_num
        
        iframe = bubStructList{i}.frameno;
        jframe = bubStructList{j}.frameno;
       framenos = [iframe, jframe] 
        
       if jframe <= iframe
            % do nothing
            
       elseif jframe == iframe + 2
            
%             % determine the cost
%             xj = bubStructList{j}.xcen; yj = bubStructList{j}.ycen;
%             xi = bubStructList{i}.xcen; yi = bubStructList{i}.ycen;
%             
%             threshold = 20;
%             xub = xi + threshold; xlb = xi - threshold;
%             yub = yi + threshold; ylb = yi - threshold;
% 
%             
%             if ((xlb <= xj) && (xj <= xub) && (ylb <= yj) && (yj <= yub))
%                 cost = 1;   % 0.1 x 10
%             else
%                 cost = 10;  % 1 x 10
%             end
%                 
            
            cost = 99999;   % set arc to be infinite 
            % create arc
            a3_str = strcat(a3_str, ['a ' int2str(bubStructList{i}.vnode) ' '... 
                                     int2str(bubStructList{j}.unode) ' ' '0 ' ...
                                     '1 ' int2str(cost) '\n']); % cost ??????????????????
                                 
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
    toc
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

end

