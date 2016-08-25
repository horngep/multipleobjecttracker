

% % training SVM (using video 2)
run('BubbleExistanceClaasifier2.m');
run('BubbleTransitionClassifier.m');
close all;

vidNo = 3;

% detection
run('XCORR_detector_matrix_multiplication.m');

% tracking
[glo_cmdout,total_acc_bub_list_n] = XCORR_Algorithm1_LZhang( total_acc_bub_list,Wa,Ba,Wt,Bt );

% making video and labeling bubbles
labeled_total_acc_bub_list = MakeLabelVideo_XCORR( glo_cmdout, total_acc_bub_list_n,vidNo );


% % getting results (save time running)
%load('var_results_3_wk6.mat'); % normal results

% % % detection evaluation
load('GT_detection_3_v2.mat'); % GT for tracking (GT = 390)
[pr_labels,pr_scores] = plot_precision_recall_curve(labeled_total_acc_bub_list,GT);

% tracking evaluation (tracking Aflation experiment not needed)
load('GT_t_tracking_3.mat');
[pr_labels_t,pr_scores_t] = plot_precision_recall_curve_t( labeled_total_acc_bub_list,GT_t );





% Aflation Experiment: Appearance cost = -C, Transac cost = +inf (to ignore
% graph)?
% i.e. What happens when we dont use graph at all (i.e. just detection)
% 
% load('Ablation'); % Aflation Experiment (Detection only)
% load('GT_detection_3_v2.mat'); % GT for tracking (GT = 390)
% [ pr_labels_a,pr_scores_a ] = plot_precision_recall_ablation( labeled_total_acc_bub_list,GT );



% TODO: improve the graph method
% after the run, compare it to untuned pr_curve
% write out a table, and chosse the one which combined AUC is highest







