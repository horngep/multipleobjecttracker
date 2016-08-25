function q = perceptron_classify(X,w)

[d,n]=size(X);
d=d+1;
X=[X ; ones(1,n)];
q=(w'*X)'>0;
