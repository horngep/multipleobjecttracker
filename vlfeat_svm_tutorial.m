% Load training data X and their labels y
vl_setup demo % to load the demo data
load('vl_demo_svm_data.mat');

Xp = X(:,y==1);
Xn = X(:,y==-1);

figure
plot(Xn(1,:),Xn(2,:),'*r')
hold on
plot(Xp(1,:),Xp(2,:),'*b')
axis equal ;


lambda = 0.01 ; % Regularization parameter
maxIter = 1000 ; % Maximum number of iterations

[w b info] = vl_svmtrain(X, y, lambda, 'MaxNumIterations', maxIter)


% Visualisation
eq = [num2str(w(1)) '*x+' num2str(w(2)) '*y+' num2str(b)];
line = ezplot(eq, [-0.9 0.9 -0.9 0.9]);
set(line, 'Color', [0 0.8 0],'linewidth', 2);








% create a structure with kernel map parameters
hom.kernel = 'KChi2';
hom.order = 2;
% create the dataset structure
dataset = vl_svmdataset(X, 'homkermap', hom);
% learn the SVM with online kernel map expansion using the dataset structure
[w b info] = vl_svmtrain(dataset, y, lambda, 'MaxNumIterations', maxIter)








