% training Bubble Existance Classifier using SVM - HAND LABEL - only uses 5
% frames

% GETTING Wa and Ba > for XCORR_Algorithm1_LZhang
% RESULT: Wa and Ba

% Parameters: contrast, size, ncc (TODO: how to obtain?)

% using SVM to train a classifier Ea (x) = Wx + b;
% where Ea >= +1 if not a bubble and Ea <= -1 if is a bubble

% Video number for training: 2
% Video number for validation:

% LOAD DATA (TODO: THIS SHOULD BE LOADED ONCE IT IS SETUP)
load('Ea_training_data1.mat')
total_acc_bub_list_training; % xcen,ycen,frameno,ncc,sigma,rho,bub_patch,unode,vnode

% 1. TRAINING SVM FOR Ea
% Frames use for training sets: 
training_frames = [31,51,71,101,121];

% 1.1 get all bubbles from the frame
training_bub_list= {};
for i = 1:length(total_acc_bub_list_training)
    for j = 1:length(training_frames)
        if total_acc_bub_list_training{i}.frameno == training_frames(j)
            training_bub_list{length(training_bub_list)+1} = total_acc_bub_list_training{i};
        end
    end
end

training_bub_list; 

% 1.2 (Hand-) Labeling classes of bubbles (from total_acc_bub_list)

% show all of them
% for k = 1:length(training_bub_list)
% 
%     subplot(10,11,k); 
%     imshow(training_bub_list{k}.bub_patch); 
%     title(num2str(training_bub_list{k}.unode));
% end

% hand_label_label = [257,258,259,260,263,264,266, ...
%                398,399,400,401,403,404,406,407, ...
%                409,567,568,569,573,575,580,586, ...
%                887,888,889,893,899,900,907, ...
%                910,1200,1201,1203,1210,1215,1229,1230];

hand_label_unode = [514,516,518,520,526,528,532,...
                    796,798,800,802,806,808,812,814,...
                    818,1134,1136,1138,1146,1150,1172,...
                    1774,1776,1778,1786,1788, 1798,1800,1814,1820,...
                    2400,2402,2404,2406,2420,2430,2458,2460];

for i = 1:length(training_bub_list)
    b = training_bub_list{i};
    isCorrect = b.unode == hand_label_unode;
    isCorrect = sum(isCorrect);
    
    if isCorrect
        b.isCorrect = 1;
    else
        b.isCorrect = -1;
    end
    training_bub_list{i} = b;
end

% check if the training bubbles looks fine
% k = 1;
% for i = 1:length(training_bub_list)
%     if training_bub_list{i}.isCorrect == 1
%         subplot(8,8,k); k = k+1;
%         imshow(training_bub_list{i}.bub_patch); title(num2str(training_bub_list{i}.label))
%     end
% end


len = length(training_bub_list);

% 1.4 Put parameters and labels into vectors (like vlfeat's tutorial)
X = zeros(2,len); % try  avg_intensity and ncc first
Y = zeros(1,len); 

for i = 1:len
    X(1,i) = training_bub_list{i}.avg_intensity; % X(1,i) = avg_intensity
    X(2,i) = training_bub_list{i}.max_ncc_val; % X(2,i) = max_ncc_val
    %X(3,i) = training_bub_list{i}.rho; % X(3,i) = rho
    Y(1,i) = training_bub_list{i}.isCorrect;
end

Xp = X(:,Y==1);
Xn = X(:,Y==-1);

figure
plot(Xn(1,:),Xn(2,:),'*r')
%scatter3(Xn(1,:),Xn(2,:),Xn(3,:),'*r')
hold on
plot(Xp(1,:),Xp(2,:),'*b')
%scatter3(Xp(1,:),Xp(2,:),Xp(3,:),'*b')
axis normal ;


% 1.5 Train SVM
lambda = 0.0001 ; % Regularization parameter
maxIter = 1000 ; % Maximum number of iterations

[Wa Ba info] = vl_svmtrain(X, Y, lambda, 'MaxNumIterations', maxIter);


% % Visualisation
% 2 param
eq = [num2str(Wa(1)) '*x+' num2str(Wa(2)) '*y+' num2str(Ba)];
line = ezplot(eq, [-2 2 -2 2]);
set(line, 'Color', [0 0.8 0],'linewidth', 2);

% for 3 param
% b0 = Ba; w1 = Wa(1); w2 = Wa(2); w3 = Wa(3);
% [x y] = meshgrid(-30:0.5:30);  
% z = (Ba - Wa(1)*x - Wa(2)*y )/Wa(3);
% mesh(x,y,z)



% NOW WE HAVE SVM classifier w and b 
% where Wa.X + Ba > 0 if y = +1 
% and   Wa.X + Ba < 0 if y = -1




