function [  ] = createDIMACSfile( bubStructList )

% CREATEDIMACSFILE Summary of this function goes here

% This function takes in list of Bubbles (struct) obtain from MSER.
% Arcs are created, and additional information are formed and 
% converted to DIMACS format which is then write into a text file.
% The text file then can be use as input for Goldberg's CS2 algorithm 
% in C, which can be run in terminal by $ cat textfile.txt | ./cs2


% INPUT: List (cell array) {} of Bubbles (struct) containing bubble
% information
% Bubble properties: b.frameno, b.x, b.y, b.unode, b.vnode

      
% Algorithm
% $ Forming source and sink node
% $ Extract Arcs (Edges) from the bubbles and number of Arcs
% $ Create and write a DIMACS file compatible for Goldberg's CS2



%   Detailed explanation goes here

%   $ Basic information:
bubble_num = size(bubStructList); bubble_num = bubble_num(2);
nodes_num = bubble_num * 2 + 2; % each bub has 2 nodes + source, sink node




%   $ Forming source and sink node
snode = 1; tnode = nodes_num;

 

%   $ Extract Arcs (Edges) from the bubbles and number of Arcs
% Format: 'a <tail> <head> <cap l.b.> <cap u.b.> <cost>'


%   Inter-Bubble Arcs
% 'a <bi.nodeid_u> <bi.nodeid_v> 0 1 <cost>';

a1_str = '';
for i = 1:bubble_num
    a1_str = strcat(a1_str, ['a ' int2str(bubStructList{i}.unode) ' '...
        int2str(bubStructList{i}.vnode) ' ' '0 ' '1 '...
        '-6\n']); % cost = -0.6 x 10 ??????????????????
end
arcs_num = bubble_num;

%   Source and Sink Arcs
% 'a <src.nodeid> <bi.nodeid_u> 0 1 <cost>';
% 'a <bi.nodeid_v> <dst.nodeid> 0 1 <cost>'
a2_str = '';
for i = 1:bubble_num
    a2_str = strcat(a2_str, ['a ' int2str(snode) ' ' int2str(bubStructList{i}.unode)...
        ' ' '0 ' '1 ' '5.441\n']); % source arc cost = 0.5441 x 10 ??????????????????
    a2_str = strcat(a2_str,['a ' int2str(bubStructList{i}.vnode) ' ' int2str(tnode)...
        ' ' '0 ' '1 ' '5.441\n']); % sink arc cost = 0.5441 x 10 ??????????????????
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
        
       if bubStructList{j}.frameno <= bubStructList{i}.frameno
            % do nothing
       
       elseif bubStructList{j}.frameno == bubStructList{i}.frameno + 2
            
            % determine the cost
            xj = bubStructList{j}.x; yj = bubStructList{j}.y;
            xi = bubStructList{i}.x; yi = bubStructList{i}.y;
            
            threshold = 20;
            xub = xi + threshold; xlb = xi - threshold;
            yub = yi + threshold; ylb = yi - threshold;

            
            if ((xlb <= xj) && (xj <= xub) && (ylb <= yj) && (yj <= yub))
                cost = 1;   % 0.1 x 10
            else
                cost = 10;  % 1 x 10
            end
                
                
            % create arc
            a3_str = strcat(a3_str, ['a ' int2str(bubStructList{i}.vnode) ' '... 
                                     int2str(bubStructList{j}.unode) ' ' '0 ' ...
                                     '1 ' int2str(cost) '\n']); % cost ??????????????????
            
            arcs_num = arcs_num + 1; % add arc counts
       
       elseif bubStructList{j}.frameno > bubStructList{i}.frameno + 2

           break;
           
       end
        
    end
    
 end

% concat arcs
a_str = strcat(a1_str, a2_str, a3_str);
 

 
%   $ Create a DIMACS file compatible for Goldberg's CS2
fileID = fopen('fakeRun.txt','w+'); % 'w+' for wiped out old stuff (if any)

% formning the 'problem line' p 
% Format: 'p min <nodes_num> <arcs_num>'
p_str = ['p min ' int2str(nodes_num) ' ' int2str(arcs_num) '\n'];
% forming the 'node line' n  
% Format: 'n <node> <flow>'
n_str = '';
n_str = strcat(n_str, ['n ' int2str(snode) ' ' '1\n']);
n_str = strcat(n_str, ['n ' int2str(tnode) ' ' '-1\n']);
                        % flows =  f(G) (see paper) * * * * * * * * * * * 

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

clear;



% Run ./cs2 for the file created in Terminal
% increase the flow (source and sink) incrementally (see paper)
% construct a new Function



end

