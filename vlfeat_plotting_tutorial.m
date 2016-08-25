% VLFeat plotting tutorials
% vl_pr

setup

% generating Data
numPos = 20 ;
numNeg = 100 ;

% Labels: 1s and -1s, classification result, associated to positive or negative label
% e.g. bubble or non-bubble, tracks or non-tracks
labels = [ones(1, numPos) -ones(1,numNeg)] ;  % sorted

% Scores: output of a classifier, associated to how confident the
% classification is positives. so high +ive scores associated to very
% confident that is this positive, where high -ive scores associated to
% very confident that this is negative
% e.g. costs, Ea, Et, output of the graph
scores = randn(size(labels)) + labels ;  % theses are just made up values




% if labels == 1 and  scores >= 0, then correctly classified
tp = bsxfun(@times,labels == 1,scores >= 0);
tn = bsxfun(@times,labels == -1, scores < 0);
t = tp + tn;

labels_t = labels(:,t==1);
scores_t = scores(:,t==1);

labels_f = labels(:,t==0);
scores_f = scores(:,t==0);


% look at the Data we have
figure(1);
plot(labels_t,scores_t,'*b')
hold on;
plot(labels_f,scores_f,'*r')
legend('correctly classified','wrongly classified')
xlabel('Reality(labels) - ones or minus ones');
ylabel('Decision(scores) - positive or negative');



% plotting Precision-Recall curve
figure(2);
vl_pr(labels, scores) ;


% getting precisions, recalls and info
[recall, precision, info] = vl_roc(labels, scores) ;


% Area Under Surve (AUC) can be used to summarize the quality of the
% ranking (scores output from the method (graph))
% - The ideal senario is when the PR curve is a perfect square, i.e.
% maximum AUC, so the higher AUC the better the 
disp(info.auc);






