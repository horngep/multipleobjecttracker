function w=sigmoid_learn(X,t,eta,iters)

[d,n] = size(X);
d = d+1;
X = [X ; ones(1,n)];
w = randn(d,1);

et = []; it = []; step = floor(iters/20);

for iter = 1:iters
    q = 1./(1+exp(-w'*X))';
    d = t-q;
    E = 0.5*d.*d;
    deda = d.*q.*(1-q);
    dedw = -X*deda;
    
    w = w - dedw*eta;

    if (~mod(iter,step))
        e = sum(E);
        et = [et, e];
        it = [it, iter];
        plot(it,et);
        grid on;
        xlabel 'iteration';
        ylabel 'sse';
        drawnow;
    end
end
