%% initialize Pmtk3
initPmtk3

%% get data 
loadData('knnClassify3c')

%% Function definition
% define distance from two different points as a function called dist which
% takes vectors p1 and p2.
dist = @(p1,p2) ((p1(1)-p2(1))^2+(p1(2)-p2(2))^2)^(1/2);
%% Acual 
k = 1;

for n=1:size(Xtest,1)
    x        = Xtest(n,:);
    D        = dist(Xtrain,x');
    [B,I]    = sort(D);
    ypred(n) = mode(ytrain(I(1:k)));
end

% plot(Xtest, ypred)
mean(ytest == ypred')