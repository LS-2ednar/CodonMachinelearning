%% Get Setup
close all,clear, clc;
codonusage =  readtable('codon_usage.csv');

%% Preprocess data inspection
%separate only for needed data
data = codonusage(:,[1,6:end]);
%change strings to categories in data. Kindoms in dataset
data.Kingdom = categorical(data.Kingdom);

%checking for missing values
missing = sum(sum(ismissing(data)));
% 3 enteries are missing these enteries are found in two lines 
% which are removed                                                                   !!!!!!!!!!!!!!!!

%get index of missing data 
badEntry = ismissing(data);
badRow = any(badEntry,2);
data = data(~badRow, :);

%Visualization to check for outliers
xValues = table2array(data(:,2:end));
yValues = categorical(table2array(data(:,1)));
figure()
subplot(1,2,1)
surf(xValues)
xlabel('Codons')
ylabel('Observations')
zlabel('Codonusage')
title('Codon usage')
subplot(1,2,2)
plot(yValues)
xlabel('Observations')
xlim([1, length(xValues)])
title('Classes')
sgtitle(['Initial Data Distribution of ', num2str(length(xValues)), ' Observations'])
% no outliers found -> no scaleing needed

%% kNN Classifier Qualitycheck ~ 2min runtime
% find k for minimal loss
crossvalloss= [];
tic()
for k = 5:50 
    disp(['Working: ',num2str((k-5)/45*100),'% done'])
    Mdl          = fitcknn(xValues,yValues,'NumNeighbors',k); 
    cvMdl        = crossval(Mdl);
    cvMdlloss    = kfoldLoss(cvMdl);
    crossvalloss = cat(1, crossvalloss, [k cvMdlloss]);
end
toc()

%% Plot of kNN Quality
figure()
plot(crossvalloss(:,1),crossvalloss(:,2))
title('kNNLoss')
xlabel('k')
ylabel('Loss')
text(10,0.15,'k = 5 equals to minmal loss 0.0645')
min(crossvalloss(:,2))

% --> HERE PLOT
% --> HERE PLOT
% --> HERE PLOT
% --> HERE PLOT
% --> HERE PLOT
% --> HERE PLOT

%For kNN Mdl use k = 5 for minimal loss

%% Classifier kNN in action with crossvalidation.
%Parameters for kNN Classifier
ValidationHoldout = 0.3;
kSet              = 5;

%Create kNN-Model and define crossvalisation holdout
Mdl = fitcknn(data, 'Kingdom','NumNeighbors', kSet);
cv  = cvpartition(Mdl.NumObservations,'HoldOut',ValidationHoldout);

%create cvMdl --> for prediction
cvMdl = crossval(Mdl,'cvpartition',cv);

%Prediction
Predictions = predict(cvMdl.Trained{1},data(test(cv),1:end));

%confusionmatrix for validation
Results = confusionmat(cvMdl.Y(test(cv)),Predictions);

%Plot Results
predictedY = resubPredict(Mdl);

figure()
cm = confusionchart(yValues,predictedY);
cm.NormalizedValues
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

for i = 1:height(cm.NormalizedValues)
    sum(sum(cm.NormalizedValues(i,:)))
end

% Figure indicates that "plm" class is not easy to be determined therfore
% further investigation is performed on the dataset
% % %% Further dataset investigation
% % plm = find(data.Kingdom=='plm');
% % new_data= data;
% % new_data(plm,:) = [];
% % 
% % 
% % %Visualization to check for outliers
% % xValues = table2array(new_data(:,2:end));
% % yValues = categorical(table2array(new_data(:,1)));
% % figure()
% % subplot(1,2,1)
% % surf(xValues)
% % xlabel('Codons')
% % ylabel('Observations')
% % zlabel('Codonusage')
% % title('Codon usage')
% % subplot(1,2,2)
% % plot(yValues)
% % xlabel('Observations')
% % xlim([1, length(xValues)])
% % title('Classes')
% % sgtitle(['Modified Data Distribution of ', num2str(length(xValues)), ' Observations'])

%% Modified observations kNN



% %% Classifier kNN in action with crossvalidation.
% %Parameters for kNN Classifier
% ValidationHoldout = 0.3;
% kSet              = 5;
% 
% %Create kNN-Model and define crossvalisation holdout
% Mdl = fitcknn(new_data, 'Kingdom','NumNeighbors', kSet);
% cv  = cvpartition(Mdl.NumObservations,'HoldOut',ValidationHoldout);
% 
% %create cvMdl --> for prediction
% cvMdl = crossval(Mdl,'cvpartition',cv);
% 
% %Prediction
% Predictions = predict(cvMdl.Trained{1},new_data(test(cv),1:end));
% 
% %confusionmatrix for validation
% Results = confusionmat(cvMdl.Y(test(cv)),Predictions);
% 
% %Plot Results
% predictedY = resubPredict(Mdl);
% 
% figure()
% cm = confusionchart(yValues,predictedY);
% cm.NormalizedValues
% cm.RowSummary = 'row-normalized';
% cm.ColumnSummary = 'column-normalized';
