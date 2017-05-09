load ../machineLearning/RF_Class_C/data/twonorm

X = inputs';
Y = outputs;

[N, D] =size(X);
%randomly split into 250 examples for training and 50 for testing
randvector = randperm(N);

X_trn = X(randvector(1:250),:);
Y_trn = Y(randvector(1:250));
X_tst = X(randvector(251:end),:);
Y_tst = Y(randvector(251:end));

% example 1:  simply use with the defaults
model = classRF_train(X_trn,Y_trn);
Y_hat = classRF_predict(X_tst,model);
fprintf('\nexample 1: error rate %f\n',   length(find(Y_hat~=Y_tst))/length(Y_tst));