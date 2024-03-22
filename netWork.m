%function netWork(name)
%
%%
% initialision of varibales
clear all
imds = imageDatastore("Rebexis","IncludeSubfolders",true,"LabelSource","foldernames");
imds = shuffle(imds);
[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.7,0.15,0.15,"randomized");
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
    if theta == 0
        xTemp = 0;
        yTemp = 0;
    else
        [xTemp,yTemp] = pol2cart(theta,1);
    end
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
    theta = thetaVal(i);
    if theta == 0
        xTemp = 0;
        yTemp = 0;
    else
        [xTemp,yTemp] = pol2cart(theta,1);
    end
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
    theta = thetaTrain(i);
    if theta == 0
        xTemp = 0;
        yTemp = 0;
    else
        [xTemp,yTemp] = pol2cart(theta,1);
    end
    x = [x; xTemp];
    y = [y; yTemp];
end
YTest = [x, y];
%%
% 

layers = [
    imageInputLayer([40 40 1],"Name","imageinput")
    convolution2dLayer([3 3],8,"Name","conv_1","Padding","same")
    %batchNormalizationLayer("Name","batchnorm_1")
    leakyReluLayer(0.1,"Name","leakyrelu_1")
    maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same")
    dropoutLayer(0.1,"Name","dropout_1")
    convolution2dLayer([3 3],16,"Name","conv_2","Padding","same")
    %batchNormalizationLayer("Name","batchnorm_2")
    leakyReluLayer(0.1,"Name","leakyrelu_2")
    maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same")
    dropoutLayer(0.1,"Name","dropout_2")
    convolution2dLayer([3 3],32,"Name","conv_3","Padding","same")
    %batchNormalizationLayer("Name","batchnorm_3")
    leakyReluLayer(0.1,"Name","leakyrelu_3")
    maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same")
    dropoutLayer(0.1,"Name","dropout_3")
    convolution2dLayer([3 3],64,"Name","conv_4","Padding","same")
    %batchNormalizationLayer("Name","batchnorm_4")
    leakyReluLayer(0.1,"Name","leakyrelu_4")
    maxPooling2dLayer([2 2],"Name","maxpool_4","Padding","same")
    dropoutLayer(0.1,"Name","dropout_4")
    fullyConnectedLayer(256,"Name","fc")
    leakyReluLayer(0.1,"Name","leakyrelu_4")
    fullyConnectedLayer(256,"Name","fc_1")
    leakyReluLayer(0.1,"Name","leakyrelu_5")
    fullyConnectedLayer(128,"Name","fc_2")
    leakyReluLayer(0.1,"Name","leakyrelu_6")
    fullyConnectedLayer(2,"Name","fc_4")
    leakyReluLayer(0.1,"Name","leakyrelu_7")
    tanhLayer("Name","tanh")
    scalingLayer("Name","scaling")
    regressionLayer("Name","regressionoutput")];


validationtables = table(imgValSamples,YValidation);
options = trainingOptions("sgdm", ...
    ValidationData = validationtables, ...
    MaxEpochs = 50, ...
    MiniBatchSize = 64, ...
    ValidationFrequency=10,...
    Plots = "training-progress",...
    InitialLearnRate=0.0002,...
    Verbose=0,...
    Shuffle="every-epoch",...
    GradientThreshold=1e7,...
    LearnRateSchedule="piecewise",...
    LearnRateDropPeriod=5,...
    LearnRateDropFactor=0.03);
    
%end

YTrain = YTrain';
lbltables = table(imgSamples,YTrain);

net = trainNetwork(lbltables,layers,options);
ypred = predict(net,imdsTest);
rmse = sqrt(mean((ypred-YTest).^2));
%%
figure(1);scatter(YTest(:,1),ypred(:,1));
figure(2);scatter(YTest(:,2),ypred(:,2));

diferense = abs(ypred(:,1)-YTest(:,1));
x = find(diferense>0.1);
figure(3);scatter(ypred(:,1),ypred(:,2));
hold on
figure(3);scatter(ypred(x,1),ypred(x,2));