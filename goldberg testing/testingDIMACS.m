
%       Bubble structures
% Bubbles
b1 = struct();
b1.frameno = 1; b1.x = 12; b1.y = 12;
% each bubble has 2 Nodes
b1.nodeid_u = 1; % Node ID
b1.nodeid_v = 2; 

b2 = struct();
b2.frameno = 2; b2.x = 12; b2.y = 12;
b2.nodeid_u = 3;
b2.nodeid_v = 4;

b3 = struct();
b3.frameno = 2; b3.x = 20; b3.y = 20;
b3.nodeid_u = 5;
b3.nodeid_v = 6;

% sink node 
t_node = struct(); 
t_node.nodeid = 7;





% Arcs Inter-Bubble 
a1 = struct();
a1.tail = b1.nodeid_u; a1.head = b1.nodeid_v;
a1.cost = 1; a1.type = 'Inter-Bubble';

a2 = struct();
a2.tail = b2.nodeid_u; a2.head = b2.nodeid_v; 
a2.cost = 1; a2.type = 'Inter-Bubble';

a3 = struct();
a3.tail = b3.nodeid_u; a3.head = b3.nodeid_v; 
a3.cost = 1; a3.type = 'Inter-Bubble';

% Transitional Arcs
a4 = struct();
a4.tail = b1.nodeid_v; a4.head = b2.nodeid_u; 
a4.cost = 3; a4.type = 'Transitional';

a5 = struct();
a5.tail = b1.nodeid_v; a5.head = b3.nodeid_u; 
a5.cost = 5; a5.type = 'Transitional';

% Sinking Arcs
a6 = struct();
a6.tail = b1.nodeid_v; a6.head = t_node.nodeid; 
a6.cost = 50; a6.type = 'Sinking';

a7 = struct();
a7.tail = b2.nodeid_v; a6.head = t_node.nodeid; 
a7.cost = 50; a7.type = 'Sinking';

a8 = struct();
a8.tail = b2.nodeid_v; a8.head = t_node.nodeid; 
a8.cost = 50; a8.type = 'Sinking';



% List
nodeList = {b1.nodeid_u, b1.nodeid_v, b2.nodeid_u, b2.nodeid_v...
    b3.nodeid_u, b3.nodeid_v, t_node};
arcList = {a1, a2, a3, a4, a5, a6, a7, a8};








%   Write to text file
fileID = fopen('myfile.txt','a+');
nodeNum = size(nodeList); nodeNum = nodeNum(2);
arcNum = size(arcList); arcNum = arcNum(2);

formatSpec1 = 'p min %d %d\n';
formatSpec2 = 'n 1 1\n';
formatSpec3 = 'n 7 -1\n';
formatSpec4 = 'a 1 2 0 1 1\n';
formatSpec5 = 'a 3 4 0 1 1\n';
formatSpec6 = 'a 5 6 0 1 1\n';
formatSpec7 = 'a 2 3 0 1 3\n';
formatSpec8 = 'a 2 5 0 1 5\n';
formatSpec9 = 'a 2 7 0 1 50\n';
formatSpec10 = 'a 4 7 0 1 20\n';
formatSpec11 = 'a 6 7 0 1 20\n';

fprintf(fileID, formatSpec1,nodeNum,arcNum);
fprintf(fileID, formatSpec2);
fprintf(fileID, formatSpec3);
fprintf(fileID, formatSpec4);
fprintf(fileID, formatSpec5);
fprintf(fileID, formatSpec6);
fprintf(fileID, formatSpec7);
fprintf(fileID, formatSpec8);
fprintf(fileID, formatSpec9);
fprintf(fileID, formatSpec10);
fprintf(fileID, formatSpec11);



fclose(fileID);
clear;








