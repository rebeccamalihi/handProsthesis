%function netWork(name)
%
%%
% initialision of varibales
clear all
imds = imageDatastore("Sub1_copy\","IncludeSubfolders",true,"LabelSource","foldernames");
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
YTrain = labels;

%% Validation Lables
labelsVal = imdsVal.Labels;
YValidation = labelsVal;

%% Testing lables
labelsTest = imdsTest.Labels;
YTest = labelsTest;
layers = [
    imageInputLayer([40 40 1],"Name","imageinput")
    convolution2dLayer([3 3],8,"Name","conv_1","Padding","same")
    batchNormalizationLayer("Name","batchnorm_1")
    leakyReluLayer(0.1,"Name","leakyrelu_4")
    averagePooling2dLayer([5 5],"Name","maxpool_1","Padding","same")
    dropoutLayer(0.1,"Name","dropout_2_1")
    fullyConnectedLayer(300,"Name","fc")
    reluLayer
    fullyConnectedLayer(400,"Name","fc_1")
    reluLayer
    fullyConnectedLayer(5,"Name","fc_2")
    reluLayer
softmaxLayer
classificationLayer];
% layers = [
%     imageInputLayer([40 40 1],"Name","imageinput")
%     convolution2dLayer([9 9],16,"Name","conv_1","Padding","same")
%     batchNormalizationLayer("Name","batchnorm_1")
%     leakyReluLayer(0.1,"Name","leakyrelu_4")
%     averagePooling2dLayer([5 5],"Name","maxpool_1","Padding","same")
%     dropoutLayer(0.1,"Name","dropout_2_1")
%     convolution2dLayer([9 9],32,"Name","conv_2","Padding","same")
%     batchNormalizationLayer("Name","batchnorm")
%     leakyReluLayer(0.1,"Name","leakyrelu_6")
%     averagePooling2dLayer([5 5],"Name","maxpool_2","Padding","same")
%     dropoutLayer(0.2,"Name","dropout_2_2")
%     fullyConnectedLayer(50,"Name","fc_1")
%     leakyReluLayer(0.1,"Name","leakyrelu_2")
%     fullyConnectedLayer(50,"Name","fc_1")
%     leakyReluLayer(0.1,"Name","leakyrelu_2")
% %     fullyConnectedLayer(400,"Name","fc_2")
% %     leakyReluLayer(0.1,"Name","leakyrelu_3")
%     %flattenLayer("Name","flatten")
%     %lstmLayer(128,"Name","lstm")
%     fullyConnectedLayer(2,"Name","fc_3")
%     tanhLayer("Name","tanh")
%     scalingLayer("Name","scaling")
%     regressionLayer("Name","regressionoutput")];


validationtables = table(imgValSamples,YValidation);
options = trainingOptions("sgdm", ...
    ValidationData = validationtables, ...
    MaxEpochs = 64, ...
    MiniBatchSize = 128, ...
    Plots = "training-progress",...
    InitialLearnRate=0.001,...
    Verbose=0,...
    Shuffle="every-epoch",...
    GradientThreshold=1e3);
    
%end

%YTrain = YTrain';
lbltables = table(imgSamples,YTrain);

net = trainNetwork(lbltables,layers,options);
ypred = predict(net,imdsTest);

