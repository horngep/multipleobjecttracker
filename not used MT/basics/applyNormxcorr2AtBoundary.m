% What does normxcorr2() do at the boundary?

p = zeros(50,50);
p(:,25:end) = 255;
p = mat2gray(p);

I = zeros(90,90);
I(:,:) = 255;
I = mat2gray(I);

KK = normxcorr2(p, I);

subplot(2,2,1); imshow(p); title('image patch 30x30');
subplot(2,2,2); imshow(I); hold on; colormap gray; axis equal off ; title('pic 90x90');
subplot(2,2,3); surf(KK); shading flat; title('xcorr plot');

% it augment the boundary with black values (0), with size of half the
% patch size that is applied to it

% this is not what we want, hence we should just get rid of the augemented
% boundary

% get rid of augmented boundary
[prow,pcol] = size(p);
MM = KK(uint16(prow/2)+1:end-uint16(prow/2), uint16(pcol/2)+1:end-uint16(pcol/2));

subplot(2,2,4); surf(MM); shading flat; title('xcorr plot after getting rid of extra boudary');


