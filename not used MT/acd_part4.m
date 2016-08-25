
% 0. Setting up
setup;
vidNo = 4;
vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are

%{
% 1A. Get image patch containing 1 bubble
Ori = imread('Image47','jpg');
I = Ori([92:126],[166:200]); % 35 x 35 patch
[patchSize,~] = size(I);
%}

% 1B. Get image patch by cropping
% 1B.1 Preprocessing preperation: PP_HERB
F = imread('Image1','jpg');
F = histeq(F); % histogram equalisation
maxIntensity = max(max(F)); % get maximum intensity of backgrond
M = zeros(size(F));
M(1:end, 1:end) = maxIntensity ; 
Q = bsxfun(@minus,M,double(F)); % Q = maximum intensity matrix - background intensity

% 1B.2 Apply PP_HERB to target image frame
i = 45;
Ori = imread(['Image' int2str(i)],'jpg');
J = histeq(Ori); % histogram equalisation
J = bsxfun(@plus,double(J),Q);  % Removing background
J = uint8(J);
% inverse it (maxValue - originalValue) so that normxcorr works well (template were inversed already)
J = 255 - J;

imshow(J)
I = imcrop;


patchSize = 100;

% 2. Get optimised parameters that maximise the NCC
tic;
opti_maxCC = -1000000000;
for ii = 1:1:44
    for jj = 1:1:15
        
        rho = ii; sigma = jj;
        % >>> PARAMETER: circleType <<<
        T = create_template(rho,patchSize,sigma,'full circle');
        
        % HACK: since we make Template really big, we swap the order of
        % normxcorr2
        CC = normxcorr2(I,T);
        % CC = normxcorr2(T,I);
        CC = CC(uint16(patchSize/2)+1:end-uint16(patchSize/2), uint16(patchSize/2)+1:end-uint16(patchSize/2));% get rid of augmented boundary

       
        maxCC = max(CC(:));
        
        if maxCC > opti_maxCC 
            opti_rho = rho;
            opti_sigma = sigma;
            opti_maxCC = maxCC;
        end
        
    end
end
toc;


% 3. visualing
% >>> PARAMETER: circleType <<<
T = create_template(opti_rho,patchSize,opti_sigma,'full circle');
% HACK: since we make Template really big, we swap the order of
% normxcorr2
CC = normxcorr2(I,T);
%CC = normxcorr2(T, I);
CC = CC(uint16(patchSize/2):end-uint16(patchSize/2), uint16(patchSize/2):end-uint16(patchSize/2));% get rid of augmented boundary


figure; 
subplot(2,3,1); imagesc(I); hold on; colormap gray; axis equal off ; title('image patch');
subplot(2,3,2); imagesc(T); hold on; colormap gray; axis equal off ; title('optimised template')
subplot(2,3,3); surf(CC); shading flat; title('xcorr plot');


% try running it over the whole image using the optimised param  
CC_J = normxcorr2(T, J);
CC_J = CC_J(uint16(patchSize/2):end-uint16(patchSize/2), uint16(patchSize/2):end-uint16(patchSize/2));% get rid of augmented boundary


% 4. Finding local maximum
pks = imregionalmax(CC_J,8);
% >>> PARAMETER: threshold <<<
threshold = 0.3;
pks_val = bsxfun(@times, CC_J, pks);
pks_fil = pks_val > threshold; % location of peaks that are higher than threshold

subplot(2,3,4); imagesc(J); hold on; colormap gray; axis equal off ; title('original image');
subplot(2,3,5); surf(CC_J); shading flat; title('xcorr plot of whole image');
subplot(2,1,2); imagesc(pks_fil); hold on; colormap gray; axis equal off ; title('show peaks (>0.4)');

% close all;

opti_rho
opti_sigma
