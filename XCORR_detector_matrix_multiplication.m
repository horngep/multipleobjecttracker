
% OUTPUT: video of accepted bubbles
% OUTPUT: list for all accepted bubbles for all frames
total_acc_bub_list = {};


tic
% 0. Setting up
setup;
% vidNo = 3;
vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are

% Video: creating video
% getting the frame rate of original video
addpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');
bubbleVideo1 = VideoReader('bubbleVideo1.avi');
rmpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');
% creating video
outputVideo = VideoWriter('matrix_mulp_xcorr_TestVid.avi'); % Video Name 
outputVideo.FrameRate = bubbleVideo1.FrameRate;
open(outputVideo)






% 1. Create templates
% 1.1 create detector template0
patchSize_0 = 31; % CONSTANT PATCHSIZE
rho0 = 9; sigma0 = 2; % >> PARAMETER: rho0 = 9, sigma0 = 2 <<
template0 = create_template(rho0,patchSize_0,sigma0, 'full circle');
% TO IMPROVE: ADD MORE DETECTOR TEMPLATE

% 1.2 precomputed bunchs of templates (connected matrices) for finding
% optimised parameters
patchSize_N = 101;

maxSigma = 7; % this will effect how paramters are found (section 6)
maxRho = 50;
Template_matrix = zeros(10201,maxRho * maxSigma);
c = 0;


for sigma = 1:1:maxSigma
    for rho = 1:1:maxRho
        c = c+1;
        
        template_K = create_template(rho,patchSize_N,sigma, 'full circle');
        norm_template_K = template_K - mean2(template_K);
        norm_template_K = norm_template_K(:);
        var_template1 = sqrt((norm_template_K.') * norm_template_K);
        t = norm_template_K / var_template1;

        Template_matrix(:,c) = t;
        
    end
end




% 2.-1 PP_HERB setup
F = imread('Image1','jpg');
F = histeq(F); 
maxIntensity = max(max(F)); 
M = zeros(size(F));
M(1:end, 1:end) = maxIntensity ; 
Q = bsxfun(@minus,M,double(F)); 



for ii = 1:2:128
    % 2. Obtain and preprocess input image frame: PP_HERB
    i = ii;
    I = imread(['Image' int2str(i)],'jpg');
    J = histeq(I); 
    J = bsxfun(@plus,double(J),Q);  
    J = uint8(J);
    J = 255 - J; % Preprocessed and inverted image (this is what we use for normxcorr2())





    % 3. Get potential bubbles
    positions = zeros(size(J));

    for scale = 0.2:0.1:1

        % 3.1 rescale J
        Jk = imresize(J,scale);


        % 3.2 Apply normxcorr2, get rid of boundary
        ncc = normxcorr2(template0,Jk);
        [t_row, t_col] = size(template0);
        t_row = int16(t_row); t_col = int16(t_col);
        ncc = ncc(t_row/2:end-t_row/2, t_col/2:end-t_col/2);


        % 3.3 find local optima and threshold it
        % local optima location (bw) and its ncc values
        loc_opt = imregionalmax(ncc);
        loc_ncc_val = bsxfun(@times, ncc, loc_opt); 

        % >>> PARAMTER: LOCAL OPTIMA THRESHOLD <<<
        loc_opt_threhold = 0.4;    % 0.4

        % thresholded local optima location (bw)
        the_loc_opt = loc_ncc_val > loc_opt_threhold;    

        % 3.4 Rescale back to exactly the same size
        Pk = imresize(the_loc_opt,size(J));

        % 3.5 Add all potential bubbles into the BW image
        positions = bsxfun(@plus,positions,Pk);        
    end

    % now we have all the (approx) LOCATIONS of potential bubbles (positions)



    % 4. Put center positions of bubbles and frame number into structs cell
    pot_bub_list = {};

    [yarr, xarr] = ind2sub(size(positions), find(positions == 1)) ;
    yarr = uint16(yarr); xarr = uint16(xarr);

    for lm = 1:length(yarr)
        p = struct();
        p.xcen = xarr(lm); p.ycen = yarr(lm); % storing center positions
        p.frameno = ii; % storing frame number
        pot_bub_list{length(pot_bub_list) + 1} = p;
    end



    % 5. get all potential bubbles patchs (with the same dimensions patchSize_N x patchSize_N)

    % 5.1 augment J with dark boundaries with size pot_patchSize/2 (51)
    half_ps_N = uint16(patchSize_N/2);
    [J_height, J_width] = size(J); 

    augmented_J = zeros(J_height + patchSize_N,J_width + patchSize_N); % [(341+51), (476+51)]
    augmented_J(half_ps_N:J_height + half_ps_N - 1,half_ps_N: J_width + half_ps_N - 1) = J;
    augmented_J = uint8(augmented_J); % augmented J
    % imshow(augmented_J)

    % 5.2 get all patches (with black patches (0) augmented if exceeding boundaries)
    for aug = 1:length(pot_bub_list)
        p = pot_bub_list{aug};

        aug_xcen = p.xcen + half_ps_N;
        aug_ycen = p.ycen + half_ps_N;

        % determine regions
        pxcorn = aug_xcen - half_ps_N; 
        pycorn = aug_ycen - half_ps_N;
        pwidth = patchSize_N - 1;
        pheight = patchSize_N - 1; 

        % get the patchs
        p.bub_patch = augmented_J(pycorn: pycorn + pheight,pxcorn: pxcorn + pwidth);
        % imshow(p.bub_patch)

        pot_bub_list{aug} = p;

    end



    % 6. apply ncc
    for pot = 1:length(pot_bub_list)

        p = pot_bub_list{pot};
        patch = p.bub_patch;
        normalised_p = p.bub_patch - mean2(patch);
        normalised_p = normalised_p(:); % normalised patch
        normalised_p = double(normalised_p);

        var_p = sqrt((normalised_p.') * normalised_p); % variance

        p_final = normalised_p/var_p;

        % ncc
        ncc_p = ((p_final.') * Template_matrix ); % Template_matrix from section 1.2


        % get max ncc values
        p.max_ncc_val = max(ncc_p);

        % get other params
        max_ncc_val_loc = ncc_p == max(ncc_p);
        col_number = find(max_ncc_val_loc);

        p.sigma = ceil(col_number/maxRho); % round up
        p.rho = rem(col_number,maxRho);

        pot_bub_list{pot} = p;

    end




    % 7. non-maximum suppression
    current_acc_bub_list = {}; % accepeted bubbles list for current frame

    % >>> PARAMETER: OVERLAP PERCENTILE <<<
    overlap_percent_threshold = 0.90 ; % (90% overlap)


    % 7.1 determine overlapping bubbles exceeding threshold
    for b = 1:length(pot_bub_list)
        b_xcen = double(pot_bub_list{b}.xcen);
        b_ycen = double(pot_bub_list{b}.ycen);
        overlap_bub_list = {};

        for d = 1:length(pot_bub_list)

            if b ~= d
                d_xcen = double(pot_bub_list{d}.xcen); 
                d_ycen = double(pot_bub_list{d}.ycen);

                del_x = abs(d_xcen - b_xcen);
                del_y = abs(d_ycen - b_ycen);

                % check if they overlap
                if (del_x < patchSize_N) && (del_y < patchSize_N)

                    % how much overlap
                    overlap_percentile = (patchSize_N - del_x)*(patchSize_N - del_y)/(patchSize_N * patchSize_N);

                    if (overlap_percentile > overlap_percent_threshold)
                        % if overlap enough, put it into the overlapping bubble list
                        overlap_bub_list{length(overlap_bub_list)+1} = pot_bub_list{d};
                    end
                end
            end
        end



    % 7.2 non-maximum suppression (using matlab_max_ncc_val) on the overlapped list

        if isempty(overlap_bub_list) % no overlap, accept it
            current_acc_bub_list{length(current_acc_bub_list)+1} = pot_bub_list{b};

        else % there are overlapping bubbles

            % check if this potential bubble has max_ncc_val higher than other overlapped bubbles
            acc = 1;

            for ov = 1:length(overlap_bub_list)
                if pot_bub_list{b}.max_ncc_val < overlap_bub_list{ov}.max_ncc_val
                    acc = 0;
                end
            end

            if acc == 1 % if it is, add it to accepted list
                current_acc_bub_list{length(current_acc_bub_list)+1} = pot_bub_list{b};
            end
        end

    end
    toc
    
    
    % 8. Put the bubbles in the current frames into list of all bubbles
    for fin = 1:length(current_acc_bub_list)
        total_acc_bub_list{length(total_acc_bub_list)+1} = current_acc_bub_list{fin};
    end
    
        % temporary disable video making

%     % visualise: Draw circles
%     img = figure(1);
% 
%     centers = zeros(length(current_acc_bub_list),2);
%     radii = zeros(length(current_acc_bub_list),1);
%     for plo = 1:length(current_acc_bub_list)
%         radii(plo,1) = current_acc_bub_list{plo}.rho;
%         centers(plo,1) = current_acc_bub_list{plo}.xcen;
%         centers(plo,2) = current_acc_bub_list{plo}.ycen;
%     end
%
%     clf; imagesc(J); hold on; colormap gray; axis equal off ; title('post filter accepted bubbles')
%     h = viscircles(centers,radii);
%     %img = figure(1);
%     
%     
%     % Video: saving to video
%     % writing it to video file
%     saveas(img,'FrameUsedToCreateVideo','jpg') % save the frame temporary
%     ImgToBeWrittenToVid = imread('FrameUsedToCreateVideo.jpg');
%     writeVideo(outputVideo,ImgToBeWrittenToVid); % write to video
%     % close(img) % close the figure
%     delete FrameUsedToCreateVideo.jpg % delete the frame once written to video
%     
end



% Video: closing video
close(outputVideo);


% resulting outcome: total_acc_bub_list
total_acc_bub_list;
 
% add the unode, vnode and labels = 0 (for MakeLabelVideo_XCORR) to all bubbles.
node_count = 2;
for nn = 1:1:length(total_acc_bub_list)
    b = total_acc_bub_list{nn};
    
    b.unode = node_count;
    node_count = node_count + 1;
    b.vnode = node_count;
    node_count = node_count + 1;
    
    b.label = 0;
    
    total_acc_bub_list{nn} = b;
    
    
end

% calculate and add avg intensity
for i = 1:length(total_acc_bub_list)
    
    b = total_acc_bub_list{i};
    bub_patch = b.bub_patch;
    rho = b.rho;
    
    no_pixel = 0; total_intensity = 0;
    
    for ind_row = -rho:1:rho
        for ind_col = -rho:1:rho
            % start from center of bub_patch
            % sum all intensity within the radius
            total_intensity = total_intensity + bub_patch(51+ind_row,51+ind_col);
            no_pixel = no_pixel + 1; % count pixel iterated over
        end
    end 
        
    % AVG_INTENSITY
    b.avg_intensity = double(total_intensity)/double(no_pixel);
    
    total_acc_bub_list{i} = b;
end



