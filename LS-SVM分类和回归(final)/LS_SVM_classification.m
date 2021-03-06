clc


load('RAW.mat');
RAW1=RAW(:,:);
RAW=RAW1(:,1:254);
LLL=RAW1(:,255);
[oo, pp]=size(RAW);
temp = randperm(oo);%训练集和预测集按照3:1分类
P_train = RAW(temp(1:300),:);
T_train = LLL(temp(1:300),:);
P_test = RAW(temp(301:end),:);
T_test = LLL(temp(301:end),:);
%% 参数设置
type = 'c';
kernel_type = 'RBF_kernel';
gam =418.3101;
sig2 =  24.41722;

preprocess = 'preprocess';
codefct = 'code_MOC';   

%% 编码

[Yc,codebook,old_codebook] = code(T_train,codefct);


%% 交叉验证优化参数
%L_fold = 10; % L-fold crossvalidation
%[gam,sig2] = tunelssvm({P_train,T_train,type,[],[],'RBF_kernel'},'simplex','crossvalidatelssvm',{L_fold,'misclass'});
%[gam,sig2] = tunelssvm({P_train,T_train,type,[],[],'RBF_kernel'},'gridsearch','crossvalidatelssvm',{L_fold,'misclass'});
%[gam,sig2] = tunelssvm({P_train,Yc,type,gam,sig2,kernel_type,preprocess});

%% 训练与测试

[alpha,b] = trainlssvm({P_train,Yc,type,gam,sig2,kernel_type,preprocess});           % 训练
Yd0 = simlssvm({P_train,Yc,type,gam,sig2,kernel_type,preprocess},{alpha,b},P_test);      % 预测集分类
Yd1 = simlssvm({P_train,Yc,type,gam,sig2,kernel_type,preprocess},{alpha,b},P_train);      % 训练集分类

%% 解码

Yd2= code(Yd0,old_codebook,[],codebook);
Yd3 = code(Yd1,old_codebook,[],codebook);


%% 结果统计

%% 结果对比
result_1 = [T_train Yd3];
result_2 = [T_test Yd2];
% 训练集正确率
k1 = length(find(T_train == Yd3));
n1 = length(T_train);
Accuracy_1 = k1 / n1 * 100;
disp(['训练集正确率Accuracy = ' num2str(Accuracy_1) '%(' num2str(k1) '/' num2str(n1) ')'])
% 测试集正确率
k2 = length(find(T_test == Yd2));
n2 = length(T_test);
Accuracy_2 = k2 / n2 * 100;
disp(['测试集正确率Accuracy = ' num2str(Accuracy_2) '%(' num2str(k2) '/' num2str(n2) ')'])

%% 绘图
figure(1)
plot(1:300,T_train,'m--+',1:300,Yd3,'b-*')
axis([1,300,0.5,4.5]);
grid on
xlabel('训练集样本编号')
ylabel('训练集集样本类别')
string = {'训练集分类结果对比(LS-SVM)';['(正确率Accuracy = ' num2str(Accuracy_1) '%)' ]};
title(string)
legend('真实值','LS-SVM预测值')
figure(2)
plot(1:100,T_test,'m--+',1:100,Yd2,'b-*')
axis([1,100,0.5,4.5]);
grid on
xlabel('测试集样本编号')
ylabel('测试集样本类别')
string = {'测试集分类结果对比(LS-SVM)';['(正确率Accuracy = ' num2str(Accuracy_2) '%)' ]};
title(string)
legend('真实值','LS-SVM预测值')


