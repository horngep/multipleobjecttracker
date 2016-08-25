opts.rootdir=fileparts(which(mfilename));
opts.rootdir(opts.rootdir=='\')='/';
opts.imgpath_src=[opts.rootdir '../src_images/%s.png'];
opts.ptspath_src=[opts.rootdir '../src_images/%s_pts.mat'];
opts.imglist_allsrc=[opts.rootdir '../src_images/all.txt'];
opts.imgsize=128;
opts.refscale=30;

opts.imgpath_reg=[opts.rootdir '/reg_images/%s.png'];
opts.imglist_train=[opts.rootdir '/reg_images/train.txt'];
opts.imglist_test=[opts.rootdir '/reg_images/test.txt'];

lbls={'neutral','smiling'};

[imgs,Ctrain]=textread(opts.imglist_train,'%s%d');
n=length(imgs);
Itrain=zeros(opts.imgsize,opts.imgsize,n);
for i=1:n
    Itrain(:,:,i)=im2double(imread(sprintf(opts.imgpath_reg,imgs{i})));
end

[imgs,Ctest]=textread(opts.imglist_test,'%s%d');
n=length(imgs);
Itest=zeros(opts.imgsize,opts.imgsize,n);
for i=1:n
    Itest(:,:,i)=im2double(imread(sprintf(opts.imgpath_reg,imgs{i})));
end

fprintf('Initialisation Done!\n');
fprintf('Now type "showimgs" to examine the training and test sets.\n');
fprintf('Alternatively, use "selfeats" to select image features.\n\n');