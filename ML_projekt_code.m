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
% which are removed 

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

%For kNN Mdl use k = 5 for minimal loss

%% Classifier kNN and Naive Bayes in action with crossvalidation.
%Parameters for kNN Classifier
ValidationHoldout = 0.3;
kSet              = 5;

%Create kNN-Model and define crossvalisation holdout
kMdl = fitcknn(data, 'Kingdom','NumNeighbors', kSet);
kcv  = cvpartition(kMdl.NumObservations,'HoldOut',ValidationHoldout);

%Create Naive Bayes Model and define cossvalidation holdout
NBMdl = fitcnb(data, 'Kingdom');
NBcv  = cvpartition(NBMdl.NumObservations, 'HoldOut',ValidationHoldout);

%create kcvMdl & NBcvMdl --> for predictions
kcvMdl = crossval(kMdl,'cvpartition',kcv);
NBcvMdl = crossval(NBMdl,'cvpartition',NBcv);

%Predictions
kPredictions = predict(kcvMdl.Trained{1},data(test(kcv),1:end));
NBPredictions = predict(NBcvMdl.Trained{1},data(test(NBcv),1:end));

%confusionmatrix for validation
kResults = confusionmat(kcvMdl.Y(test(kcv)),kPredictions);
NBResukts = confusionmat(NBcvMdl.Y(test(NBcv)),NBPredictions);

%Plot kNN Results
kpredictedY = resubPredict(kMdl);

figure()
Orgcm = confusionchart(yValues,kpredictedY);
Orgcm.NormalizedValues
Orgcm.RowSummary = 'row-normalized';
Orgcm.ColumnSummary = 'column-normalized';


%%
% The following is concluded 

%----------------------------------------%
%     Data Reorganization is needed      %
%----------------------------------------%

%excluding plm
plm = find(data.Kingdom=='plm');
data(plm,:) = [];

%combining pln,vrt,inv,man,rod, and pri as euk
%get inices
pln = find(data.Kingdom == 'pln');
inv = find(data.Kingdom == 'inv');
vrt = find(data.Kingdom == 'vrt');
mam = find(data.Kingdom == 'mam');
rod = find(data.Kingdom == 'rod');
pri = find(data.Kingdom == 'pri');
%change class
data.Kingdom(pln) = 'euk';
data.Kingdom(inv) = 'euk';
data.Kingdom(vrt) = 'euk';
data.Kingdom(mam) = 'euk';
data.Kingdom(rod) = 'euk';
data.Kingdom(pri) = 'euk';

%adding phg to vrl
phg = find(data.Kingdom == 'phg');
data.Kingdom(phg) = 'vrl';

%new number of classes is 5
unique(data.Kingdom)

%save data in new variable
newdata = data;
newdata.Kingdom = setcats(newdata.Kingdom,{'arc','bct','vrl','euk'});
struct(newdata.Kingdom)

%% New Data kNN Classifier Qualitycheck ~2min runtime

% find k for minimal loss
crossvalloss= [];
tic()
xValues = newdata(:,2:end);
nyValues = newdata.Kingdom;
for k = 5:50 
    disp(['Working: ',num2str((k-5)/45*100),'% done'])
    Mdl          = fitcknn(xValues,yValues,'NumNeighbors',k); 
    cvMdl        = crossval(Mdl);
    cvMdlloss    = kfoldLoss(cvMdl);
    crossvalloss = cat(1, crossvalloss, [k cvMdlloss]);
end
toc()

%% Plot of new Quality Check
figure()
plot(crossvalloss(:,1),crossvalloss(:,2))
title('kNNLoss')
xlabel('k')
ylabel('Loss')
text(10,0.15,'k = 5 equals to minmal loss 0.0790')
min(crossvalloss(:,2))
text(10,0.1,'k = 5')
text(10,0.0965,'Loss = 0.0507')

%% Classifier kNN and Naive Bayes in action with crossvalidation.
%Parameters for kNN Classifier
ValidationHoldout = 0.3;
kSet              = 5;

%Create kNN-Model and define crossvalisation holdout
nkMdl = fitcknn(newdata, 'Kingdom','NumNeighbors', kSet);
nkcv  = cvpartition(nkMdl.NumObservations,'HoldOut',ValidationHoldout);

%create kcvMdl & NBcvMdl --> for predictions
nkcvMdl = crossval(nkMdl,'cvpartition',nkcv);


%Predictions
nkPredictions = predict(nkcvMdl.Trained{1},data(test(nkcv),1:end));

%confusionmatrix for validation
nkResults = confusionmat(nkcvMdl.Y(test(nkcv)),nkPredictions);

%Plot kNN Results
nkpredictedY = resubPredict(nkMdl);

figure()
% subplot(1,2,1)
% Orgcm = confusionchart(yValues,kpredictedY);
% Orgcm.NormalizedValues
% Orgcm.RowSummary = 'row-normalized';
% Orgcm.ColumnSummary = 'column-normalized';
% 
% subplot(1,2,2)
Ncm = confusionchart(nyValues,nkpredictedY);
Ncm.NormalizedValues
Ncm.RowSummary = 'row-normalized';
Ncm.ColumnSummary = 'column-normalized';

% Data is nolonger evenly distributed which is why hte arc group was kicked
% out and giveing each class identical weights
%% create newestdataset
%remove arc
newdata(find(newdata.Kingdom == 'arc'),:) = [];
newestdata = newdata;
%set new categories
newestdata.Kingdom = setcats(newestdata.Kingdom,{'bct','vrl','euk'});
struct(newestdata.Kingdom)
%%

%Number to weight all data evenly
NumCU = 2000;
kTest = 5;
ValidationHoldout = 0.3;
Runs = 5000


%Initializations please dont touch
acc = [];

%get get individual data for each class
bct = newestdata(find(newestdata.Kingdom == 'bct'),:);
vrl = newestdata(find(newestdata.Kingdom == 'vrl'),:);
euk = newestdata(find(newestdata.Kingdom == 'euk'),:);

%%%
%start for loop
%%%
for i = 1:Runs

fprintf('%i Runs DONE out of %i\n', (i-1),Runs)


%picking data
%-----------%
%getin randomized and equaly weight bacterial data:
%random in species
rnumbrs = randperm(size(bct,1));
%choose indexes
rindex = rnumbrs(1:NumCU);
%get data
rbct = bct(rindex,:);

%random in species
rnumbrs = randperm(size(vrl,1));
%choose indexes
rindex = rnumbrs(1:NumCU);
%get data
rvrl = vrl(rindex,:);


%random in species
rnumbrs = randperm(size(euk,1));
%choose indexes
rindex = rnumbrs(1:NumCU);
%get data
reuk = euk(rindex,:);

%Create final randomicesed dataset 
testdata  = [rbct;rvrl;reuk];
testindex = randperm(size(testdata,1));
testdata = testdata(testindex,:);
TyValues = testdata.Kingdom;

%-------------%
%kNN Clasifier%
%-------------%
%Parameters for kNN Classifier

%Create kNN-Model and define crossvalisation holdout
nkMdl = fitcknn(testdata, 'Kingdom','NumNeighbors', kTest);
nkcv  = cvpartition(nkMdl.NumObservations,'HoldOut',ValidationHoldout);

%create kcvMdl & NBcvMdl --> for predictions
nkcvMdl = crossval(nkMdl,'cvpartition',nkcv);

%Predictions
nkPredictions = predict(nkcvMdl.Trained{1},data(test(nkcv),1:end));

%confusionmatrix for validation
nkResults = confusionmat(nkcvMdl.Y(test(nkcv)),nkPredictions);

%Plot kNN Results
nkpredictedY = resubPredict(nkMdl);

% figure()
Ncm = confusionchart(TyValues,nkpredictedY);
% Ncm.NormalizedValues;
% Ncm.RowSummary = 'row-normalized';
% Ncm.ColumnSummary = 'column-normalized';

%Bacteria
hit   = Ncm.NormalizedValues(1,1);
total = sum(Ncm.NormalizedValues(1,:));
accBct= hit/total;
%Viruses
hit   = Ncm.NormalizedValues(2,2);
total = sum(Ncm.NormalizedValues(2,:));
accVrl= hit/total;
%
%Viruses
hit   = Ncm.NormalizedValues(3,3);
total = sum(Ncm.NormalizedValues(3,:));
accEuk= hit/total;

addition = [accBct,accVrl,accEuk];
acc = [acc;addition];
% Means ausgeben und mittelwerte berechnen
% treffer durch total

end
figure()
Ncm = confusionchart(TyValues,nkpredictedY);
Ncm.NormalizedValues;
Ncm.RowSummary = 'row-normalized';
Ncm.ColumnSummary = 'column-normalized';


% %%%
% %End for loop
% %%%

%Evalueate accuary to fit something correctly in specified class
% disp(acc)

mBct = mean(acc(:,1));
mVrl = mean(acc(:,2));
mEuk = mean(acc(:,3));

means = [mBct,mVrl,mEuk];


%%
means

