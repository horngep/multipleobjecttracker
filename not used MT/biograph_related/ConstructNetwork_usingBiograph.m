function [ BGobj ] = ConstructNetwork( outputBubbleCell )
% INPUT: outputBubbleCell from the results of MSER from each preprocessing
% methods
% OUTPUT: Biograph object


% -- Mapping outputBubbleCell into Biograph object

%   - Count no of bubbles
bubCounts = 0;
numCell = size(outputBubbleCell);
numCell = numCell(2);                               % Number of Cells (i.e. number of Frames)
numBubList = size(numCell,1);

for i = 1:numCell   
    noOfBubInThisCell = size(outputBubbleCell{i});
    bubCounts = bubCounts + noOfBubInThisCell(2);
    numBubList(i,1) = noOfBubInThisCell(2);
    
end
bubCounts;                                          % Number of Bubbles
numBubList;

%   - Forming CMatrix
CMatrix = zeros(bubCounts*2);


% u1 -> v1, u2 -> v2, ...etc
for j = 1:2:bubCounts*2        
    CMatrix(j,j+1) = 1;
end


% v1 -> u2, v1 -> u3, ...etc, NOTE: THIS CODE IS PRETY MUCH HARD CODED
p = 2; q = 1;
for m = 1:numCell-1
    
    noOfBubInThisCell = size(outputBubbleCell{m});
    noOfBubInThisCell = noOfBubInThisCell(2);
    noOfBubInNextCell = size(outputBubbleCell{m+1});
    noOfBubInNextCell = noOfBubInNextCell(2);
    
    if (noOfBubInThisCell > 0 && noOfBubInNextCell > 0) % only have edge for bubble in successive frame 
        
        for n = 1:noOfBubInThisCell
            for r = 1:noOfBubInNextCell
                col = q + 2*r;
                CMatrix(p,col) = 3;               
            end         
            p = p + 2;
        end
        q = q + 2*noOfBubInNextCell;
    end
    
    
    if (noOfBubInThisCell > 0 && noOfBubInNextCell == 0) % skip a bubble (both v and u)
        p = p + 2;
        q = q + 2;
    end
end
sparse(CMatrix);
size(CMatrix);













% ~~~~~~~~~~~~~~~~~~ Code below are usable for biograph objects +
% Some info inside each bubble (frame no, coordinates) *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%   - Forming NodeIDs
count = 1;
for s = 1:bubCounts
   
   ustr = strcat('u',num2str(s));
   vstr = strcat('v',num2str(s));
   
   NodeIDs{count} = ustr;
   count = count + 1;
   NodeIDs{count} = vstr;
   count = count + 1;
   
end
NodeIDs;                                            % list of u1, v1, u2, v2...


% --  Construct Biograph Object ~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!!!!!!!!!!!!!
BGobj = biograph(CMatrix,NodeIDs);



%   Obtain all x , y coordinates of all bubble in an array   ***
bubCoordinatesArray = zeros(1,bubCounts);
c = 1;
for ii = 1:numCell     % for every cell
    
    noOfBubInThisCell = size(outputBubbleCell{ii});
    noOfBubInThisCell = noOfBubInThisCell(2);
    
    if(noOfBubInThisCell > 0)
        
        for jj = 1:noOfBubInThisCell   % for every array inside the cell
            arr = outputBubbleCell{ii}{jj};
            bubCoordinatesArray(1,c) = arr(1);
            c = c + 1;
            bubCoordinatesArray(1,c) = arr(2);
            c = c + 1;
        end               
    end
end
bubCoordinatesArray;                             % Array of coordinates


%   Obtain all frame numbers of each bubbles in an array (note: each bubble
%   has u and v)  ***
frameNo = 1;
d = 1; 
frameNoArray = zeros(1,bubCounts);
for ii = 1:numCell     % for every cell
    
    noOfBubInThisCell = size(outputBubbleCell{ii});
    noOfBubInThisCell = noOfBubInThisCell(2);
    
    if (noOfBubInThisCell == 0)
        frameNo = frameNo + 2;
    else
        for ll = 1:noOfBubInThisCell
            frameNoArray(d) = frameNo;
            d = d + 1;
            frameNoArray(d) = frameNo;
            d = d + 1;
        end
        frameNo = frameNo + 2;
    end
    
end
frameNoArray;                                   % Array of Frame numbers


%   Iterate throguh each Node, assign coordinates and Frame Numbers
for u_jh = 1:bubCounts*2 
    BGobj.Nodes(u_jh).Description = num2str(bubCoordinatesArray(u_jh));  
    BGobj.Nodes(u_jh).Position = [frameNoArray(u_jh),0];
    BGobj.Nodes(u_jh).Shape = 'ellipse';
    BGobj.Nodes(u_jh).Label = NodeIDs{u_jh};
end


% -- Improve Visualisation
%   Adjust position to correspond to its frame number



%   Modify the edge color of Biograph object
noOfEdges = size(BGobj.Edges);
noOfEdges = noOfEdges(1);

% if weight > 1, then blue, if weight = 3 then red
for mm = 1:noOfEdges
   if (BGobj.Edges(mm).Weight == 1)
       BGobj.Edges(mm).LineColor = [1,0,0]; % Make edge red
   elseif (BGobj.Edges(mm).Weight == 3)
       BGobj.Edges(mm).LineColor = [0,1,0]; % Make edge blue
   end
end



% -- Plot Biograph object
view(BGobj);


clear i j p q m n count ii jj kk ll c ;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
end

