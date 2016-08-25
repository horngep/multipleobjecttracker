function [ bubStructListHistRB ] = Preprocess_HisEqRB_MSER()
%   Detailed explanation goes here



% -- get background and hence Q
F = imread('Image1','jpg');

F = histeq(F); % histogram equalisation
maxIntensity = max(max(F)); % get maximum intensity of backgrond
M = zeros(size(F));
M(1:end, 1:end) = maxIntensity ; 

Q = bsxfun(@minus,M,double(F)); % Q = maximum intensity matrix - background intensity

noBubHistRB = zeros(1,64); % create number of bubbles matrix





k = 1; % iterator; where Frame Number = 2k-1
node_count = 2;
bub_struct_count = 0;
for i = 1:2:128
     
 I = imread(['Image' int2str(i)],'jpg');
 I = histeq(I); % histogram equalisation
 
 J = bsxfun(@plus,double(I),Q); % Remove background
 J = uint8(J);
 
 % -- Apply MSER
 [r,f] = vl_mser(J,'DarkOnBright',1, 'MaxArea', 0.1, 'MinArea', 0.001, 'Delta', 10,...
    'MinDiversity', 0.95);  % get region seeds (parameters are now for vid 2)

  s = size(r);
 noBubHistRB(k) = s(1); % Get number of bubbles detected

 
  % -- Create BubStructList
  
  noOfBubCurrentFrame = size(f);
  noOfBubCurrentFrame = noOfBubCurrentFrame(2);
 
  for i = 1:noOfBubCurrentFrame
      
      % create bubble structure
      bub_struct_count = bub_struct_count + 1;
      b = struct(); b.frameno = 2*k - 1;
      b.x = f(1,i); b.y = f(2,i);
      b.unode = node_count; node_count = node_count + 1;
      b.vnode = node_count; node_count = node_count + 1;
      
      bubStructListHistRB{bub_struct_count} = b;
      
  end
 
 
 k = k+1;   
end
 bubStructListHistRB;

end

