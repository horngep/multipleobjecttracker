q=perceptron_classify(Xtest,w);

C=zeros(2,2);
for i=1:2
    for j=1:2
        C(i,j)=sum(Ctest==i-1&q==j-1);
    end
end

n=sum(C(:));
c=trace(C);
cpc=c*100/n;

fprintf('       |neutral|smiling\n')
fprintf('-----------------------\n');
fprintf('neutral|%7d|%7d\n', C(1,:));
fprintf('-----------------------\n');
fprintf('smiling|%7d|%7d\n', C(2,:));
fprintf('\nnb: correct output is in rows\n');
fprintf('\n');
fprintf('overall accuracy: %.1f%% (%d out of %d)\n', cpc, c, n);

fprintf('\nUse "showresults" to see which faces were classified correctly.\n');
fprintf('Return to the "selfeats" step to choose new features.\n\n');
