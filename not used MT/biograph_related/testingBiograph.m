M = [0,1,0;0,0,2;0,0,0];
names = {'A','B','C'};
BG = biograph(M,names);


BG.Nodes(1).Position = [100,100];
BG.Nodes(2).Position = [200,100];
BG.Nodes(3).Position = [300,200];

BG.Nodes(3).Label = names{3};

BG.Edges(1)
BG.Edges(1)

