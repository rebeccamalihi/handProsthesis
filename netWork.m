%function netWork(name)

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
xtemp = [];
ytemp = [];
thetaTrain = double(string(labels));
for i = 1:length(thetaTrain)
    theta = thetaTrain(i);
    switch theta
        case theta == 0
            xtemp = 0;
            yTemp = 0;
        case theta == 90
            xtemp = 0;
            ytemp = 1;
        case theta == 180
            xtemp = -1;
            ytemp = 0;
        case theta == 270
            xtemp = 0;
            ytemp = -1;
        case theta == 360
            xtemp = 1;
            ytemp = 0;
    end
    x = [x;xtemp];
    y = [y;ytemp];

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
%% base neuralnet structure

mainPath = [
    imageInputLayer([40 40 1],"Name","imageinput",Normalization="none")
    convolution2dLayer([3 3],8,"Name","conv_1","Padding","same")
    %batchNormalizationLayer("Name","batchnorm_1")
    leakyReluLayer(0.1,"Name","leakyrelu_1")
    %maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same")
    %dropoutLayer(0.1,"Name","dropout_1")
    convolution2dLayer([3 3],16,"Name","conv_2","Padding","same")
    %batchNormalizationLayer("Name","batchnorm_2")
    leakyReluLayer(0.1,"Name","leakyrelu_2")
    %maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same")
    %dropoutLayer(0.1,"Name","dropout_2")
    convolution2dLayer([3 3],32,"Name","conv_3","Padding","same")
    %batchNormalizationLayer("Name","batchnorm_3")
    leakyReluLayer(0.1,"Name","leakyrelu_3")
    %maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same")
    %dropoutLayer(0.1,"Name","dropout_3")
    convolution2dLayer([3 3],32,"Name","conv_4","Padding","same")
    %batchNormalizationLayer("Name","batchnorm_4")
    leakyReluLayer(0.1,"Name","leakyrelu_4")
    %maxPooling2dLayer([2 2],"Name","maxpool_4","Padding","same")
    %dropoutLayer(0.1,"Name","dropout_4")
    fullyConnectedLayer(400,"Name","fc")
    leakyReluLayer(0.1,"Name","leakyrelu_5")
    fullyConnectedLayer(200,"Name","fc_1")
    leakyReluLayer(0.1,"Name","leakyrelu_6")
    fullyConnectedLayer(100,"Name","fc_2")
    leakyReluLayer(0.1,"Name","leakyrelu_7")];
%% classification section
classificationPath = [
    fullyConnectedLayer(5,"Name","fc_3")
    leakyReluLayer(0.1,"Name","leakyrelu_8")
    %tanhLayer("Name","tanh")
    scalingLayer("Name","scaling")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];


classificationNet = layerGraph();
classificationNet = addLayers(classificationNet,mainPath);
classificationNet = addLayers(classificationNet,classificationPath);
classificationNet = connectLayers(classificationNet,"leakyrelu_7","fc_3");
plot(classificationNet)

% options
class_validationtables = table(imgValSamples,imdsVal.Labels); % validation data
lossThreshold = 0.3;
classificationOptions = trainingOptions("sgdm", ...
    ValidationData = class_validationtables, ...
    MaxEpochs = 50, ...
    MiniBatchSize = 64, ...
    ValidationFrequency=20,...
    Plots = "training-progress",...
    InitialLearnRate=0.0001,...
    Verbose=0,...
    Shuffle="every-epoch",...
    OutputNetwork="best-validation",...
    GradientThreshold=inf,...
    OutputFcn = @(info)stopTraining(info,lossThreshold));


 class_lbltables = table(imgSamples,imdsTrain.Labels);
trainedClassNet = trainNetwork(class_lbltables,classificationNet,classificationOptions);
%%
regressionPath = [
    fullyConnectedLayer(2,"Name","fc_3")
    leakyReluLayer(0.1,"Name","leakyrelu_8")
    tanhLayer("Name","tanh")
    scalingLayer("Name","scaling")
    regressionLayer("Name","regressionoutput")];

regressionNet = layerGraph();
regressionNet = addLayers(regressionNet,trainedClassNet.Layers);
regressionNet = removeLayers(regressionNet,["fc_3","leakyrelu_8","scaling","softmax","classoutput"]);
regressionNet = addLayers(regressionNet,regressionPath);
regressionNet = connectLayers(regressionNet,"leakyrelu_7","fc_3");
plot(regressionNet)



%     regressionLayer("Name","regressionoutput")];
% layers = [
%     imageInputLayer([40 40 1],"Name","input_1","Normalization","none")
%     convolution2dLayer([3 3],64,"Name","conv_1")
%     reluLayer("Name","relu_input_1")
%     fullyConnectedLayer(300,"Name","fc_1")
%     reluLayer("Name","relu_body")
%     fullyConnectedLayer(400,"Name","fc_body")
%     reluLayer("Name","body_output")
%     fullyConnectedLayer(2,"Name","output")
%     tanhLayer("Name","tanh")
%     regressionLayer("Name","regressionoutput")];

%% regression network

validationtables = table(imgValSamples,YValidation);
regressionOptions = trainingOptions("sgdm", ...
    ValidationData = validationtables, ...
    MaxEpochs = 50, ...
    MiniBatchSize = 64, ...
    ValidationFrequency=10,...
    Plots = "training-progress",...
    InitialLearnRate=0.00001,...
    Verbose=0,...
    Shuffle="every-epoch",...
    OutputNetwork="best-validation",...
    GradientThreshold=inf);

YTrain = YTrain';
lbltables = table(imgSamples,YTrain);
net = trainNetwork(lbltables,regressionNet,regressionOptions);
ypred = predict(net,imdsTest);
rmse = sqrt(mean((ypred-YTest).^2));
%%
figure(1);scatter(YTest(:,1),ypred(:,1));
figure(2);scatter(YTest(:,2),ypred(:,2));

diferense = sqrt((ypred(:,1)-YTest(:,1)).^2 + (ypred(:,2)-YTest(:,2)).^2);
x = find(diferense>0.4);
figure(3);scatter(ypred(:,1),ypred(:,2));
hold on
figure(3);scatter(ypred(x,1),ypred(x,2));
figure(4);boxplot(ypred(:,1),YTest(:,1));
figure(5);boxplot(ypred(:,2),YTest(:,2));


function stop = stopTraining(info,lossThreshold)
    trainingLoss = info.TrainingLoss;
    stop = trainingLoss < lossThreshold;
end