figure(1);
clf reset;
set(gcf,'DoubleBuffer','on');
set(gcf,'Name','training images');
for i=1:n
    subplot(ceil(n/ceil(sqrt(n))),ceil(sqrt(n)),i);
    imagesc(Itrain(:,:,i),[0 1]);
    text(5,10,lbls(Ctrain(i)+1),'Color','r');
    axis image;
    axis off;
    colormap gray;
    drawnow;
end

figure(2);
clf reset;
set(gcf,'DoubleBuffer','on');
set(gcf,'Name','test images');
for i=1:n
    subplot(ceil(n/ceil(sqrt(n))),ceil(sqrt(n)),i);
    imagesc(Itest(:,:,i),[0 1]);
    text(5,10,lbls(Ctest(i)+1),'Color','r');
    axis image;
    axis off;
    colormap gray;
    drawnow;
end
