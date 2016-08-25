function X=rectfeats(I,RC)

ni=size(I,3);
nf=size(RC,3);
ra=prod(RC(:,2,:)-RC(:,1,:)+1);

X=zeros(nf,ni);
for i=1:ni
    for f=1:nf
        X(f,i)=sum(sum(I(RC(2,1,f):RC(2,2,f),RC(1,1,f):RC(1,2,f),i)))/ra(f);
    end
end
