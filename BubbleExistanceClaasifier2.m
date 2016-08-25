
% training Bubble Existance Classifier using SVM - HAND LABEL (but uses result from 
% BubbleExistanceClassifier1) - MORE DATA - AS WE USES ALL FRAMES




load('Ea_training_data2.mat');

labeled_total_acc_bub_list_training;

% label = 0 + all false negative (hand label - from labeled_total_acc_bub_list)
false_negative_label = [0,1,2,3,4,5,7,8,12,13,14,15,16,17,...
    18,19,20,21,22,23,24,25,32,38,56,59,60,63,68,73,220,263,311,312,322,329]; 


for i = 1:length(labeled_total_acc_bub_list_training)
    b = labeled_total_acc_bub_list_training{i};
    % find all the wrong
    is_notCorrect = sum(b.label == false_negative_label); % 1 or 0 
    
    if is_notCorrect
        b.isCorrect = -1; 
    else
        b.isCorrect = 1;
    end
    labeled_total_acc_bub_list_training{i} = b;
end





len = length(labeled_total_acc_bub_list_training);

% 1.4 Put parameters and labels into vectors (like vlfeat's tutorial)
X = zeros(2,len); % try  avg_intensity and ncc first
Y = zeros(1,len); 

for i = 1:len
    X(1,i) = labeled_total_acc_bub_list_training{i}.avg_intensity; % X(1,i) = avg_intensity
    X(2,i) = labeled_total_acc_bub_list_training{i}.max_ncc_val; % X(2,i) = max_ncc_val
    Y(1,i) = labeled_total_acc_bub_list_training{i}.isCorrect;
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
lambda = 0.001 ; % Regularization parameter
maxIter = 1000 ; % Maximum number of iterations

[Wa, Ba, info] = vl_svmtrain(X, Y, lambda, 'MaxNumIterations', maxIter);


% % Visualisation
% 2 param
eq = [num2str(Wa(1)) '*x+' num2str(Wa(2)) '*y+' num2str(Ba)];
line = ezplot(eq, [-2 2 -2 2]);
set(line, 'Color', [0 0.8 0],'linewidth', 2);


% visualising the application of Wa and Ba to the data
% figure;
% Xn; 
% res_n = zeros(1,length(Xn));
% for i = 1:length(res_n)
%     res_n(1,i) = dot(Wa,Xn(:,i)) + Ba;
% end
% res_n = sort(res_n);
% plot(res_n,'*r'); hold on;
% 
% Xp; 
% res_p = zeros(1,length(Xp));
% for i = 1:length(res_p)
%     res_p(1,i) = dot(Wa,Xp(:,i)) + Ba;
% end
% res_p = sort(res_p);
% plot(res_p,'*b');

% k = 1;
% 
% for i = 1:length(labeled_total_acc_bub_list_training)
%     b = labeled_total_acc_bub_list_training{i};
%     if b.isCorrect
%         subplot(20,20,k);
%         k = k+1;
%         imshow(b.bub_patch);
%     end
% 
% end


% >> THIS PART SHOWS WHY HIGH AVG INTENSITY MEANS FALSE DETECTION <<
% figure(2); title('bubbles with avg_intensity >= 10');
% 
% k = 1;
% for i = 100:length(labeled_total_acc_bub_list_training)
%     b = labeled_total_acc_bub_list_training{i};
%     if b.avg_intensity >= 20
%         subplot(10,10,k); k = k+1; imshow(b.bub_patch);
%     end
% end

