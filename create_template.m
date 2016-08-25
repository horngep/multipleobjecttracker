function [ T ] = create_template( rho, patchSize, sigma, typeOfBub )

% PART 1: Create Circle

% C is binary image patch of a Circle radius Rho
% INPUT: rho - radius of circle. (radius x 2 should be < patchSize)
%        patchSize - keep it to be ODD NUMBER <<<<<<<<<<<<<<<<<
%        sigma - gaussian blur
%        typeOfBub - can be: 'full circle', 'right half circle', 'left half
%        circle' ( can add up and down as well)

% OUTPUT: circle binary matrix C - white background(1) and dark circle(0)

if ~mod(patchSize,2)
    errordlg('patch Size should be ODD number');
    % so that the circle can be at central position
end
if (rho*2 >= patchSize)
     errordlg('Error radius x 2 should be smaller than patchSize');
end

%{
if (rho*2 >= patchSize-10)
     errordlg('Error radius x 2 should be smaller than patchSize - 10');
end
%}

% create circle and make them white
C = zeros(patchSize,patchSize);
C(:,:) = 1;    

xc1 = int16(patchSize/2); % center of circle
yc1 = int16(patchSize/2);

% make inside region of circle black
for ii = xc1-(int16(rho)):xc1+(int16(rho))
    for jj = yc1-(int16(rho)):yc1+(int16(rho))
        tempR = sqrt((double(ii)-double(xc1)).^2 + (double(jj) - double(yc1)).^2);
        if(tempR <= double(int16(rho)))
            C(ii,jj) = 0;
        end
    end
end


% PART 2: deal with half circle and cut out excess part

%{
% 2.1 cutting out excess part
% (patchSize should be ODD number)
ps_2 = int8(patchSize/2);
C = C(ps_2-rho-5:ps_2+rho+5,ps_2-rho-5:ps_2+rho+5);


% 2.2 deal with half circle
[new_patchSize,~] = size(C); % still symmetric
xc2 = int16(new_patchSize/2);

if strcmp(typeOfBub,'full circle')
    % do nothing
    
    
elseif strcmp(typeOfBub,'left half circle')
    % translate circle left
    C = imtranslate(C,[xc2,0]);
    C = C(:,xc2:end);
    
    
elseif strcmp(typeOfBub,'right half circle')
    % translate circle right
    C = imtranslate(C,[-xc2,0]);
    C = C(:,1:xc2);
    
end
%}  

% PART 3 : create Template apply convolution with Gaussian
% INPUT: sigma, binary circle
% OUTPUT: template T, which is circle (or half circle) convolved with gaussian function

G = fspecial('gaussian',[patchSize, patchSize], sigma);
T = imfilter(C,G,'same');

% inverse black and white - to perform normalised cross-correlation
T = 1 - T;

end

