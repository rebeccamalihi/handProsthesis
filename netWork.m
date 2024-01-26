%function netWork(name)
% 
%%
% initialision of varibales

imds = imageDatastore("Reb\","IncludeSubfolders",true,"LabelSource","foldernames");
imds = shuffle(imds);
[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.7,0.15,0.15,"randomized");
% imdsTrain = transform(imdsTrain, @(x) rescale(x));
% imdsVal = transform(imdsVal, @(x) rescale(x));
% imdsTest = transform(imdsTest, @(x) rescale(x));
imgSamples = {};
YTrain = {};

%% Training dataset
for k =1:length(imdsTrain.Labels)
    filename = imdsTrain.Files{k};
    imgSamples{k} = filename;
end
imgSamples = imgSamples';

%% Validation dataset
imgValSamples = {};
for j =1:length(imdsVal.Labels)
    filename = imdsVal.Files{j};
    imgValSamples{j} = filename;
end
imgValSamples = imgValSamples';

%% Training labels
labels = imdsTrain.Labels;
x = [];
y = [];
i = 0;
thetaTrain = deg2rad(double(string(labels)));
for i = 1:length(thetaTrain) 
    theta = thetaTrain(i);
    [xTemp,yTemp] = pol2cart(theta,1);
    x = [x;xTemp];
    y = [y;yTemp];
end
response = x;%table(x,y);
response (:,:,2)= y; 
i = 0; 
for i = 1:length(response)
    YTrain{i} = response(i,:,:);
end
%% Validation Lables
labelsVal = imdsVal.Labels;
x = [];
y = [];
i = 0;
thetaVal = deg2rad(double(string(labelsVal)));
for i = 1:length(thetaVal)
    [xTemp,yTemp] = pol2cart(thetaVal(i),1);
    x = [x;xTemp];
    y = [y;yTemp];
end
responseVal = x;
responseVal (:,:,2)= y;
for l = 1:length(responseVal)
    YValidation{l} = response(l,:,:);
end
YValidation = YValidation';
%% Testing lables
labelsTest = imdsTest.Labels;
x = [];
y = [];
i = 0;
thetaTest = deg2rad(double(string(labelsTest)));
for i = 1:length(thetaTest)
    [xTemp,yTemp] = pol2cart(thetaTest(i),1);
    x = [x;xTemp];
    y = [y;yTemp];
end
YTest = [x,y];
%%

layers = [
    imageInputLayer([40 40 1],"Name","imageinput")
    convolution2dLayer([5 5],64,"Name","conv","Padding","same")
    reluLayer("Name","relu")
    fullyConnectedLayer(10,"Name","fc")
    reluLayer("Name","relu_1")
    fullyConnectedLayer(10,"Name","fc_1")
    reluLayer("Name","relu_2")
    fullyConnectedLayer(10,"Name","fc_2")
    reluLayer("Name","relu_3")
    fullyConnectedLayer(10,"Name","fc_3")
    reluLayer("Name","relu_4")
    fullyConnectedLayer(10,"Name","fc_4")
    reluLayer("Name","relu_5")
    fullyConnectedLayer(10,"Name","fc_5")
    reluLayer("Name","relu_6")
    %fullyConnectedLayer(2,"Name","fc_3")
    fullyConnectedLayer(2,"Name","fc_6")
    scalingLayer("Name","scaling")
    regressionLayer("Name","regressionoutput")];

    %ValidationData = {imgValSamples,YValidation}, ...
options = trainingOptions("adam", ...
    MaxEpochs = 60, ...
    MiniBatchSize = 32, ...
    Plots = "training-progress",...
    InitialLearnRate=0.002,...
    Verbose=0,...
    Shuffle="every-epoch",...
    GradientThreshold=1e4);
%end

YTrain = YTrain';
lbltables = table(imgSamples,YTrain);
net = trainNetwork(lbltables,layers,options);
ypred = predict(net,imdsTest);
rmse = sqrt(mean((ypred-YTest).^2));
figure(1);scatter(YTest(:,1),ypred(:,1));
figure(2);scatter(YTest(:,2),ypred(:,2));



