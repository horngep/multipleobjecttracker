% creating 7 fake detections ( runable by createDIMACSfile(bubStructList) )

fakeBubStructList = {};

b = struct(); % bubble A
b.x = 10; b.y = 10; b.frameno = 1;
b.unode = 2; b.vnode = 3;
b.label = 0;
fakeBubStructList{1} = b;

b = struct(); % A
b.x = 8; b.y = 12; b.frameno = 3;
b.unode = 4; b.vnode = 5;
b.label = 0;
fakeBubStructList{2} = b;

b = struct(); % bubble B
b.x = 52; b.y = 52; b.frameno = 3;
b.unode = 6; b.vnode = 7;
b.label = 0;
fakeBubStructList{3} = b;

b = struct(); % C
b.x = 85; b.y = 100; b.frameno = 3;
b.unode = 16; b.vnode = 17;
b.label = 0;
fakeBubStructList{4} = b;

b = struct(); % C
b.x = 100; b.y = 85; b.frameno = 3;
b.unode = 18; b.vnode = 19;
b.label = 0;
fakeBubStructList{5} = b;

b = struct(); % A
b.x = 12; b.y = 12; b.frameno = 5;
b.unode = 8; b.vnode = 9;
b.label = 0;
fakeBubStructList{6} = b;

b = struct(); % B
b.x = 54; b.y = 54; b.frameno = 5;
b.unode = 10; b.vnode = 11;
b.label = 0;
fakeBubStructList{7} = b;

b = struct(); % C
b.x = 90; b.y = 90; b.frameno = 5;
b.unode = 12; b.vnode = 13;
b.label = 0;
fakeBubStructList{8} = b;

b = struct(); % A
b.x = 15; b.y = 7; b.frameno = 7;
b.unode = 14; b.vnode = 15;
b.label = 0;
fakeBubStructList{9} = b;



glo_cmdout = Algorithm1_Zhang(fakeBubStructList);

makeLabeledVideo(glo_cmdout,fakeBubStructList);

