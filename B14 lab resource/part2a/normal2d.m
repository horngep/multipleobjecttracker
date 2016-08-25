% generate values for a 2D normal distribution

function z = normal2d(x,y,mu,C)
     
m = length(x);
n = length(y);
z = zeros(n,m);
c = 1/(2*pi*sqrt(det(C)));
S = inv(C);
for i=1:n
    for j=1:m
        xvec = [x(j);y(i)];
        z(i,j) = c * exp(-0.5 * (xvec-mu)' * S * (xvec-mu));
    end
end

