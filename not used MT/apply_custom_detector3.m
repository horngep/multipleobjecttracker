% NOT USING

tic
% 0. Setting up
setup;
vidNo = 2;
vidPath = '/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video/bubbleImage';
vidPath = strcat(vidPath,num2str(vidNo));
addpath(vidPath); % adding path where images are

%{
% Video: creating video
% getting the frame rate of original video
addpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');
bubbleVideo1 = VideoReader('bubbleVideo1.avi');
rmpath('/Users/ihorng/Documents/MATLAB/Oxford/4yp/Bubbles video');
% creating video
outputVideo = VideoWriter('XcorrTestVid.avi'); % Video Name 
outputVideo.FrameRate = bubbleVideo1.FrameRate;
open(outputVideo)
%}


% 1. Create a few templates

% >>> PARAMETER: PATCH SIZE <<<
patchSize = 101; 

rho_arr = [10,15,20,25,30,35,40,45];
sigma = 2;

template_list = {};
cir_type = {'full circle', 'right half circle', 'left half circle'}; % to detect all types of bubbles
for cir = 1:length(cir_type)
    for rr = 1:length(rho_arr)
        T = create_template(rho_arr(rr),patchSize,sigma, cir_type{cir});
        template_list{length(template_list)+1} = T;
    end
end
toc



% FOR ALL FRAMES
% bubStructList_xcorr = {};

%for i = 1:2:128
    i = 47;
    current_frame = i
    % 2. Apply normxcorr2 to each preprocessed image frame
    % 2.1 Preprocessing preperation: PP_HERB
    F = imread('Image1','jpg');
    F = histeq(F); % histogram equalisation
    maxIntensity = max(max(F)); % get maximum intensity of backgrond
    M = zeros(size(F));
    M(1:end, 1:end) = maxIntensity ; 
    Q = bsxfun(@minus,M,double(F)); % Q = maximum intensity matrix - background intensity

    % 2.2 Apply PP_HERB to target image frame
    I = imread(['Image' int2str(i)],'jpg');
    J = histeq(I); % histogram equalisation
    J = bsxfun(@plus,double(J),Q);  % Removing background
    J = uint8(J);
    % inverse it (maxValue - originalValue) so that normxcorr works well (template were inversed already)
    J = 255 - J; % Preprocessed and inverted image (this is what we use for normxcorr2())

    % 2.3 Apply normxcorr2
    % >>> PARAMETER: PEAKS THRESHOLD <<<
    threshold = 0.4; % 0.4

    for ncc = 1:length(template_list)
        
        [t_row, t_col] = size(template_list{ncc});
        nc = normxcorr2(template_list{ncc},J);  
        nc = nc(t_row/2:end-t_row/2, t_col/2:end-t_col/2); % get rid of augmented boundary

        % 2.4 Find local maxima above threshold
        pks = imregionalmax(nc);
        pks_val = bsxfun(@times, nc, pks);
        pks_fil = pks_val > threshold; % Binary Matrix: local maxima above thresold

        locMax_BW_list{ncc} = pks_fil; % list of local maxima binary matrix for each template
    end
    toc






    % 3. Find all potential bubbles
    % p = struct(); p.xcen, p.ycen
    % 3.1 Find all potential bubbles
    pot_bub_list = {}; % list of all potential bubbles

    for lml = 1:length(locMax_BW_list)
        [yarr, xarr] = ind2sub(size(locMax_BW_list{lml}), find(locMax_BW_list{lml} == 1)) ;
        length(xarr);
        for lm = 1:length(xarr)
            p = struct();
            p.xcen = xarr(lm); p.ycen = yarr(lm);
            pot_bub_list{length(pot_bub_list) + 1} = p;
        end
    end


    % 3.2 Fitting regions to all the potential bubbles
    % p = struct(); p.xcorner, p.ycorner, p.width, p.height
    [img_height, img_width] = size(I);

    for pbl = 1:length(pot_bub_list)

        p = pot_bub_list{pbl};

        % Fitting regions
        p.xcorner = p.xcen - int16(patchSize/2); 
        p.ycorner = p.ycen - int16(patchSize/2);
        p.height = patchSize - 1; p.width = patchSize - 1;

        % Modify regions if it exceeds original image input dimension 
        % for corner points
        if p.xcorner < 1
            p.width = p.width + p.xcorner - 1;
            p.xcorner = 1;
        end
        if p.ycorner < 1
            p.height = p.height + p.ycorner - 1;
            p.ycorner = 1;
        end

        % for height and width
        if (p.xcorner + p.width > img_width)
            p.width = img_width - p.xcorner;
        end
        if (p.ycorner + p.height > img_height)
            p.height = img_height - p.ycorner;
        end

        pot_bub_list{pbl} = p;
    end
    toc

    %{
    % debug: visualised all the dots from locMax_BW_list, check with location
    % of centers (should be the same)
    dbg1 = zeros(size(J));
    for deb = 1:length(locMax_BW_list)
        dbg1 = bsxfun(@plus, double(dbg1), double(locMax_BW_list{deb}));
    end
    figure(5);
    imagesc(dbg1); hold on; colormap gray; axis equal off ;
    %}
    
    % Visualisation: look at location of thresholded local maxima
    dbg2 = zeros(size(J));
    figure(4)
    imagesc(J); hold on; colormap gray; axis equal off;
    for deg = 1:length(pot_bub_list)
        p = pot_bub_list{deg};
        % dbg2(p.ycen,p.xcen) = 1;
        plot(p.xcen,p.ycen, '*');
    end
    
    %{
    % debug: check location of bouding boxes
    labeled_array = zeros(1,length(pot_bub_list));
    boxes = zeros(length(pot_bub_list),4);
    k = 0;
    for plo = 1:length(pot_bub_list)
        k = k + 1;
        labeled_array(plo) = k;
        boxes(plo,1) = pot_bub_list{plo}.xcorner;
        boxes(plo,2) = pot_bub_list{plo}.ycorner;
        boxes(plo,3) = pot_bub_list{plo}.width;
        boxes(plo,4) = pot_bub_list{plo}.height;
    end
    K = insertObjectAnnotation(J,'rectangle',boxes,labeled_array,'TextBoxOpacity',0.4,'FontSize',8);
    figure(5);
    imagesc(K); hold on; colormap gray; axis equal off ;



    % debug: see size of patchs (zz) and visualise all patchs
    figure(6);
    zz = zeros(length(pot_bub_list),2);
    kk = 1;
    for deb = 1:length(pot_bub_list)
        p = pot_bub_list{deb};
        patchy = J(p.ycorner: p.ycorner+p.height, p.xcorner:p.xcorner+p.width);
        [zza, zzb] = size(patchy);
        zz(deb,1) = zza;
        zz(deb,2) = zzb;
        subplot(7,7,kk); imshow(patchy);
        kk = kk+1;
    end
    zz;
    %}


    % 4. Find optimised param and xcorr score for each potential bubbles
    for pbl = 1:length(pot_bub_list)

        % getting patchs
        p = pot_bub_list{pbl};
        pot_patch = J(p.ycorner: p.ycorner+p.height, p.xcorner:p.xcorner+p.width);
        [pot_r, pot_c] = size(pot_patch); 
        pot_size = pot_r * pot_c;
        
        % find optimised param and xcorr
        p.opti_maxCC = -1000000000;
        sig_arr = [1,2,3,5,7];
        for rho_in = 1:1:45
            for sig_in = 1:length(sig_arr)
                for ct = 1:length(cir_type)

                    T = create_template(rho_in,patchSize,sig_arr(sig_in),cir_type{ct});

                    [T_r,T_c] = size(T);
                    T_size = T_r * T_c;
                    
                    %  >>>>>>>>>>>>>>>>>>>>>>>> BUG <<<<<<<<<<<<<<<<<<<<<<<<<<<<
                    if T_size >= pot_size
                        % cheated, swapped tempalte and patch, as patch is smaller
                        CC = normxcorr2(pot_patch,T); % C = normxcorr2(template, A), A > template;
                        [pot_patch_r, pot_patch_c ] = size(pot_patch);
                        CC = CC(uint16(pot_patch_r/2):end-uint16(pot_patch_r/2), uint16(pot_patch_c/2):end-uint16(pot_patch_c/2));% get rid of augmented boundary
                    else
                        CC = normxcorr2(T,pot_patch);                      
                        CC = CC(uint16(T_r/2):end-uint16(T_r/2), uint16(T_c/2):end-uint16(T_c/2));
                    end
                    
                    maxCC = max(CC(:));

                    if maxCC > p.opti_maxCC 
                        p.opti_rho = rho_in;
                        p.opti_sigma = sig_arr(sig_in);
                        p.cir_type = cir_type{ct};
                        p.opti_maxCC = maxCC;
                    end
                    toc
                end
            end
        end    
        pot_bub_list{pbl} = p;

    end
    toc







    % 5. Perform Non-maximum suppression (sort of) to ruled out duplicates
    acc_bub_list = {}; % accepeted bubbles list

    % >>> PARAMETER: OVERLAP PERCENTILE <<<
    overlap_percentile = 0.85; % 80% overlap

    for pbl1 = 1:length(pot_bub_list) % for each potential bubble

        p1 = pot_bub_list{pbl1};
        overlap_bub_list = {};

        % 5.1 Check for overlapping region
        %  *** HOW DO WE DEFINE OVERLAP, IS THIS CRUCIAL TO THE PERFORMANCE ? ***

        for pbl2 = 1:length(pot_bub_list) % check for every other bubble
            if pbl1 ~= pbl2 

                p2 = pot_bub_list{pbl2};

                % consider 3 cases, to find overlapping region
                % for x
                if p1.xcorner == p2.xcorner

                    if p1.width <= p2.width
                        del_x = p1.width;
                    else
                        del_x = p2.width;
                    end

                elseif (p1.xcorner < p2.xcorner)
                    del_x = (p1.xcorner + p1.width) - p2.xcorner;
                else
                    del_x = (p2.xcorner + p2.width) - p1.xcorner;
                end

                % for y
                if p1.ycorner == p2.ycorner
                    if p1.height <= p2.height
                        del_y = p1.height;
                    else
                        del_y = p2.height;
                    end

                elseif (p1.ycorner < p2.ycorner)
                    del_y = (p1.ycorner + p1.height) - p2.ycorner;
                else
                    del_y = (p2.ycorner + p2.height) - p1.ycorner;
                end


                % check if overlapp
                if del_x > 0 && del_y > 0

                    % 4.2.2 see if overlapping region exceeds threshold
                    p1area = p1.width * p1.height;
                    p2area = p2.width * p2.height;
                    avg_area = (p1area + p2area) / 2;
                    del_area = del_x * del_y;


                    if (del_area > overlap_percentile * avg_area)
                        overlap_bub_list{length(overlap_bub_list) + 1} = p2;
                    end

                end

            end
        end

        % 5.2 Non-maximum suppression (sort of)

        if isempty(overlap_bub_list) % no overlap, accept it
            acc_bub_list{length(acc_bub_list)+1} = p1;

        else % there are overlapping bubbles

            % check if p1 has opti_maxCC higher than other overlapped bubbles
            acc = 1;
            for ovl = 1:length(overlap_bub_list)
                po = overlap_bub_list{ovl};

                if p1.opti_maxCC > po.opti_maxCC
                    acc = 0;
                end
            end

            if acc == 1 % if it is, add it to accepted list
                acc_bub_list{length(acc_bub_list)+1} = p1;
            end
        end

    end
    acc_bub_list;
    toc

    %{
    % Visualisation: Accepted bubbles with their optimised Templates
    k = 1;
    figure(2);
    for vis = 1:length(acc_bub_list)
        p = acc_bub_list{vis};
        opt_T = create_template(p.opti_rho,patchSize,p.opti_sigma,p.cir_type);
        patcha = J(p.ycorner: p.ycorner+p.height,p.xcorner:p.xcorner+p.width);

        subplot(8,8,k); imagesc(opt_T); hold on; colormap gray; axis equal off ;
        k = k + 1; 

        subplot(8,8,k); imagesc(patcha); hold on; colormap gray; axis equal off ;
        k = k + 1;
    end
    %}

    % Visualisation, Refinement: Augment all bubbles to the original image,
    % with approximate radius (0.5 * h,height of optimised template) and its 
    % range (0.25 * h and 0.75 * h)

    % Draw circles
    centers = zeros(length(acc_bub_list),2);
    radii = zeros(length(acc_bub_list),1);
    for plo = 1:length(acc_bub_list)
        radii(plo,1) = acc_bub_list{plo}.opti_rho;
        centers(plo,1) = acc_bub_list{plo}.xcen;
        centers(plo,2) = acc_bub_list{plo}.ycen;
    end
    figure(1);
    imagesc(J); hold on; colormap gray; axis equal off ;
    h = viscircles(centers,radii);
    img = figure(1); % for video
    
    
    %{
    % draw bounding boxes
    labeled_array = zeros(1,length(acc_bub_list));
    boxes = zeros(length(acc_bub_list),4);
    k = 0;
    for plo = 1:length(acc_bub_list)
        k = k + 1;
        labeled_array(plo) = k;
        boxes(plo,1) = acc_bub_list{plo}.xcorner;
        boxes(plo,2) = acc_bub_list{plo}.ycorner;
        boxes(plo,3) = acc_bub_list{plo}.width;
        boxes(plo,4) = acc_bub_list{plo}.height;

    end
    K = insertObjectAnnotation(J,'rectangle',boxes,labeled_array,'TextBoxOpacity',0.4,'FontSize',8);
    figure(3);
    imagesc(K); hold on; colormap gray; axis equal off ;
    %}


    % 6. Save it to the bub struct list
    % b.unode, b.vnode, b.frameno, b.label = 0, what is b.x and b.y ?
    % bubStructList_xcorr{} ?
    toc
    
    %{
    % Video: saving to video
    % writing it to video file
    saveas(img,'FrameUsedToCreateVideo','jpg') % save the frame temporary
    ImgToBeWrittenToVid = imread('FrameUsedToCreateVideo.jpg');
    writeVideo(outputVideo,ImgToBeWrittenToVid); % write to video
    % close(img) % close the figure
    delete FrameUsedToCreateVideo.jpg % delete the frame once written to video
    %}
    
% end

% Video: closing video
% close(outputVideo);














rmpath(vidPath); % remove path where images are when done
