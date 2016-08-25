nrc=size(RC,3);
figure(4);
clf reset;
set(gcf,'DoubleBuffer','on');
set(gcf,'Name','extracted features');
for i=1:nrc
    for j=i:nrc
        subplot(nrc,nrc,(j-1)*nrc+i);
        plot(Xtrain(i,Ctrain==0),Xtrain(j,Ctrain==0),'b+', ...
            Xtrain(i,Ctrain==1),Xtrain(j,Ctrain==1),'r+');
        xlabel(sprintf('rectangle %d', i));
        ylabel(sprintf('rectangle %d', j));
        drawnow;
    end
end
