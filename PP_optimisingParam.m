
% Ground Truth of video 2
noBubGT2 = [0, 0, 1, 1, 1, 1, 0, 0,... 
           0, 0, 2, 4, 6, 6, 5, 5,... 
           4, 3, 3, 5, 6, 6, 6, 6,... 
           6, 6, 6, 5, 6, 6, 6, 6,...
           6, 6, 6, 6, 6, 6, 6, 6,... 
           6, 6, 6, 6, 6, 6, 6, 6,... 
           6, 6, 5, 5, 3, 3, 3 ,3,... 
           4, 5, 5, 5, 5, 4, 4, 4 ];


% Initial MSER PARAMETERS SETTING
mser_param = struct();
mser_param.MaxArea = 0.1;
mser_param.MinArea = 0.0005;
mser_param.Delta = 6;
mser_param.MinDiversity = 0.92;

%{
tic;
noBubArray_HERB = PP_HERB(mser_param,2);
diff = bsxfun(@minus,noBubArray_HERB,noBubGT2);
if all(diff>=0)
    g = 'great'
end
toc                
%}


% Optimised four parameters for PP_HERB
% Cost function: Minimize Sum(noBubDetect_i(black box ish) - noBubGT_i) 
% Constaints: (noBubDetect_i - noBubGT) >= 0
tic;
minSumDiff = 1000000000000;
mser_optimal_param = struct();
for MaxA = 0.05:0.05:0.1
    for MinA = 0.0005:0.0005:0.0015
        for D = 1:1:6
            for MinD = 0.92:0.02:0.98
                mser_param.MaxArea = MaxA;
                mser_param.MinArea = MinA;
                mser_param.Delta = D;
                mser_param.MinDiversity = MinD;
                
                noBubArray_HERB = PP_STMRRM(mser_param,2);
                diff = bsxfun(@minus,noBubArray_HERB,noBubGT2);
                
                % if all elements in diff are positive
                if all(diff >= 0)
                    sumDiff = sum(diff);
                    if sumDiff <= minSumDiff
                        minSumDiff = sumDiff;
                        mser_optimal_param = mser_param;
                    end
                    
                end
                toc
                
            end
        end
    end
end



















%{
% Applying preprocessing methods, getting array of bubbles for each
noBubArray_HERB = PP_HERB(mser_param,2);
noBubArray_HERRM = PP_HERRM(mser_param,2);
noBubArray_STM = PP_STM(mser_param,2);
noBubArray_STMRB = PP_STMRB(mser_param,2);
noBubArray_STMRRM = PP_STMRRM(mser_param,2);
noBubArray_RemBaseVid = PP_RemBaseVid(mser_param,2);
%}
