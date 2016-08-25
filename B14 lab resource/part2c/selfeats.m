maxrc=8;

MU0=im2double(imread(sprintf(opts.imgpath_reg,'neutral_mean')));
MU1=im2double(imread(sprintf(opts.imgpath_reg,'smiling_mean')));

figure(3);
clf reset;
set(gcf,'DoubleBuffer','on');
set(gcf,'Name','selected features');
imagesc(cat(2,MU0,MU1),[0 1]);

axis image;
axis off;
colormap gray;

clrs=[1 0 0 ; 1 1 0 ; 0 1 0 ; 0 1 1 ; 0 0 1 ; 1 0 1 ; 1 1 1; 0 0 0];

nrc=1;
title(sprintf('Editing feature %i',nrc));
if (~exist('rc','var'))
    rc = zeros(2,2,maxrc); 
    fprintf('Initializing new feature vector.\n\n');
elseif ( ndims(rc)~=3 || any(size(rc)~=[2,2,maxrc]) )
    rc = zeros(2,2,maxrc); 
    fprintf('Initializing new feature vector.\n\n');
else
    fprintf('Using previous feature vector\n   -- type "clear rc" at the MATLAB prompt to start from scratch.\n\n');
end

rh = zeros(maxrc,i);
for i=1:maxrc
    rh(i)=line(0,0,'Color',clrs(i,:));
    x1=rc(1,1,i);
    y1=rc(2,1,i);
    x2=rc(1,2,i);
    y2=rc(2,2,i);
    set(rh(i),'XData',[x1 x2 x2 x1 x1]);
    set(rh(i),'YData',[y1 y1 y2 y2 y1]);
end
drawnow;
    
vgg_event_wait clear
while 1
    [x, y, button, type] = vgg_event_wait;    
    x=min(max(round(x),1),2*opts.imgsize);
    y=min(max(round(y),1),opts.imgsize);
    if button==1
        if type==1
            set(rh(nrc),'XData',x);
            set(rh(nrc),'YData',y);
            rc(:,1,nrc)=[x ; y];
            rc(:,2,nrc)=0;
            drawnow;
        elseif type==0 || type==-1
            if ~isnan(rh(nrc))
                x1=rc(1,1,nrc);
                y1=rc(2,1,nrc);
                if x1<=size(MU0,2)
                    x=min(x,opts.imgsize);
                else
                    x=max(x,opts.imgsize+1);
                end
                rc(:,2,nrc)=[x ; y];
                x2=rc(1,2,nrc);
                y2=rc(2,2,nrc);
                set(rh(nrc),'XData',[x1 x2 x2 x1 x1]);
                set(rh(nrc),'YData',[y1 y1 y2 y2 y1]);
                drawnow;
            end
        end
    elseif button==3
        set(rh(nrc),'XData',0);
        set(rh(nrc),'YData',0);
        rc(:,:,nrc)=0;
        drawnow;
    elseif button>='1'&button<'1'+maxrc
        nrc=button-'1'+1;
        title(sprintf('Editing feature %i',nrc));
    elseif button==' '
        break
    end
end

RC=rc(:,:,all(all(rc)));
RC(RC>opts.imgsize)=RC(RC>opts.imgsize)-opts.imgsize;
RC=cat(2,min(RC,[],2),max(RC,[],2));

fprintf('Features selected!\n');
fprintf('Now use "extfeats" to extract these features from all the images.\n');
fprintf('This reduces each image to a single point in %i-dimensional space.\n\n',size(RC,3));



