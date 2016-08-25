% DONE USING


% template 1
patchSize_N = 101;

Ts = zeros(10201,50);
sigma = 1;
c = 0;
for rho = 1:1:50
    c = c+1;

    template_K = create_template(rho,patchSize_N,sigma, 'full circle');
    norm_template_K = template_K - mean2(template_K);
    norm_template_K = norm_template_K(:);
    var_template1 = sqrt((norm_template_K.') * norm_template_K);
    t = norm_template_K / var_template1;

    Ts(:,c) = t;
end


% p1
p1 = pot_bub_list{80};
patch1 = p1.bub_patch;

norm_p1 = p1.bub_patch - mean2(patch1);
norm_p1 = norm_p1(:);
norm_p1 = double(norm_p1);

var_p1 = sqrt((norm_p1.') * norm_p1);

p1_final = norm_p1/var_p1;

% my ncc
ncc_p1 = ((p1_final.') * Ts );



    
    