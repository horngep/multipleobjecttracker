eta=0.1;    % learning rate
iters=2000; % number of iterations

figure(5);
clf reset;
set(gcf,'DoubleBuffer','on');
set(gcf,'Name','training');
title('Training')

w=sigmoid_learn(Xtrain,Ctrain,eta,iters);

fprintf('Classifier trained!\n\n');

for i=1:size(RC,3)
    fprintf('rectangle %d: weight %g\n', i, w(i));
end
fprintf('bias: %g\n\n', w(i+1));

fprintf('Now type "test" to see how your classifier performs on the unseen test data.\n\n');

