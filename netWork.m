%function netWork(name)

clear all
imds = imageDatastore("Rebexis","IncludeSubfolders",true,"LabelSource","foldernames");
imds = shuffle(imds);
[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.8,0.1,0.1,"randomized");

YTrain = {};

%% Training dataset
imgSamples = {};
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
        xTemp = round(xTemp);
        yTemp = round(yTemp);
    end
    x = [x;xTemp];
    y = [y;yTemp];
    response = [x,y];
end
%% 
trainTable = table(imgSamples,response);
%% Validation dataset
imgValSamples = {};
for j =1:length(imdsVal.Labels)
    filename = imdsVal.Files{j};
    imgValSamples{j} = filename;
end
imgValSamples = imgValSamples';
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
        xTemp = round(xTemp);
        yTemp = round(yTemp);
    end
    x = [x;xTemp];
    y = [y;yTemp];
end
responseVal = [x,y];
%%
validationTable = table(imgValSamples,responseVal);

%% test
labelsTest = imdsTest.Labels;
x = [];
y = [];
i = 0;
thetaTest = deg2rad(double(string(labelsTest)));
for i = 1:length(thetaTest)
    theta = thetaTest(i);
    if theta == 0
        xTemp = 0;
        yTemp = 0;
    else
        [xTemp,yTemp] = pol2cart(theta,1);
        xTemp = round(xTemp);
        yTemp = round(yTemp);
    end
    x = [x; xTemp];
    y = [y; yTemp];
end
YTest = [x,y];
for k =1:length(imdsTest.Labels)
    filename = imdsTest.Files{k};
    imgTest{k} = filename;
end

%%
imgTest = imgTest';
testTable = table(imgTest,YTest);
testSamples = table(imgTest);

%% network layers
mainPath = [
    imageInputLayer([40 40 1],"Name","imageinput",Normalization="none")
    convolution2dLayer([3 3],8,"Name","conv_1","Padding","same")

    leakyReluLayer(0.1,"Name","leakyrelu_1")
    maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same")
    dropoutLayer(0.1,"Name","dropout_1")
    convolution2dLayer([3 3],16,"Name","conv_2","Padding","same")

    leakyReluLayer(0.1,"Name","leakyrelu_2")
    maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same")
    dropoutLayer(0.1,"Name","dropout_2")
    convolution2dLayer([3 3],32,"Name","conv_3","Padding","same")

    leakyReluLayer(0.1,"Name","leakyrelu_3")
    maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same")
    dropoutLayer(0.1,"Name","dropout_3")
    convolution2dLayer([3 3],32,"Name","conv_4","Padding","same")

    leakyReluLayer(0.1,"Name","leakyrelu_4")
    maxPooling2dLayer([2 2],"Name","maxpool_4","Padding","same")
    dropoutLayer(0.1,"Name","dropout_4")
    fullyConnectedLayer(128,"Name","fc")
    leakyReluLayer(0.1,"Name","leakyrelu_5")
    fullyConnectedLayer(256,"Name","fc_1")
    leakyReluLayer(0.1,"Name","leakyrelu_6")
    fullyConnectedLayer(128,"Name","fc_2")
    leakyReluLayer(0.1,"Name","leakyrelu_7")];

regressionPath = [
    fullyConnectedLayer(2,"Name","fc_3")
    leakyReluLayer(0.1,"Name","leakyrelu_8")
    tanhLayer("Name","tanh")
    scalingLayer("Name","scaling")
    regressionLayer("Name","regressionoutput")];

regressionNet = layerGraph();
regressionNet = addLayers(regressionNet,mainPath);
regressionNet = addLayers(regressionNet,regressionPath);
regressionNet = connectLayers(regressionNet,"leakyrelu_7","fc_3");
plot(regressionNet)

%% regression network

regressionOptions = trainingOptions("sgdm", ...
    ValidationData = validationTable, ...
    MaxEpochs = 50, ...
    MiniBatchSize = 64, ...
    ValidationFrequency=20,...
    Plots = "training-progress",...
    InitialLearnRate=0.0001,...
    Verbose=0,...
    Shuffle="every-epoch",...
    OutputNetwork="best-validation",...
    GradientThreshold=1e5);


net = trainNetwork(trainTable,regressionNet,regressionOptions);
ypred = predict(net,imdsTest);
rmse = sqrt(mean((ypred-YTest).^2));
%%
figure(1);scatter(YTest(:,1),ypred(:,1));
figure(2);scatter(YTest(:,2),ypred(:,2));

diferense = sqrt((ypred(:,1)-YTest(:,1)).^2 + (ypred(:,2)-YTest(:,2)).^2);
x = find(diferense>0.3);
figure(3);scatter(ypred(:,1),ypred(:,2));
hold on
figure(3);scatter(ypred(x,1),ypred(x,2));
figure(4);boxplot(ypred(:,1),YTest(:,1));
figure(5);boxplot(ypred(:,2),YTest(:,2));


function stop = stopTraining(info,lossThreshold)
    trainingLoss = info.TrainingLoss;
    stop = trainingLoss < lossThreshold;
end