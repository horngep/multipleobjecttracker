% NOT USED

tic
p1 = pot_bub_list{80};
patch1 = p1.bub_patch;

patchSize_N = 101;


% matlab's ncc
p1.opti_maxCC = -1000000000;
sig_arr = [1];

for rho_in = 1:1:50
    for sig_in = 1:length(sig_arr)

            T = create_template(rho_in,patchSize_N,sig_arr(sig_in),'full circle');

            % cheated, swapped tempalte and patch, as patch is smaller
            CC = normxcorr2(patch1,T); % C = normxcorr2(template, A), A > template;

            % get rid of augmented boundary
            [pot_patch_h, pot_patch_w ] = size(patch1);
            CC = CC(uint16(pot_patch_h/2):end-uint16(pot_patch_h/2), uint16(pot_patch_w/2):end-uint16(pot_patch_w/2));


            maxCC = max(CC(:));

            if maxCC > p1.opti_maxCC 
                p1.opti_rho = rho_in;
                p1.opti_sigma = sig_arr(sig_in);
                p1.opti_maxCC = maxCC;
            end
            
    end
end    

opti_T = create_template(p1.opti_rho,patchSize_N,p1.opti_sigma,'full circle');
    
p1.opti_rho
p1.opti_sigma

toc