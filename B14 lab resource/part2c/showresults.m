
lbls={'neutral','smiling'};
clrs={'r','g'};

figure(6);
clf reset;
set(gcf,'DoubleBuffer','on');
set(gcf,'Name','testing');
n=size(Itest,3);
for i=1:n
    subplot(ceil(n/ceil(sqrt(n))),ceil(sqrt(n)),i);
    imagesc(Itest(:,:,i),[0 1]);    
    text(5,10,lbls(q(i)+1),'Color',clrs{(q(i)==Ctest(i))+1});
    axis image;
    axis off;
    colormap gray;
    drawnow;
end
