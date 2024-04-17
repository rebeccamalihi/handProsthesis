clear all
imds = imageDatastore("Rebexis","IncludeSubfolders",true,"LabelSource","foldernames");
imds = shuffle(imds);
[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.8,0.1,0.1,"randomized");
imgSamples = {};
YTrain = {};
for k =1:length(imdsTrain.Labels)
    filename = imdsTrain.Files{k};
    imgSamples{k} = filename;
end
imgSamples = imgSamples';
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
%%
layers = [
    imageInputLayer([40 40 1],"Name","input_1","Normalization","none")
    convolution2dLayer([3 3],16,"Name","conv_1")
    reluLayer("Name","relu_input_1")
    convolution2dLayer([3 3],32,"Name","conv_2")
    reluLayer("Name","relu_input_2")
    convolution2dLayer([3 3],64,"Name","conv_3")
    reluLayer("Name","relu_input_3")
    fullyConnectedLayer(300,"Name","fc_1")
    reluLayer("Name","relu_4")
    fullyConnectedLayer(400,"Name","fc_body")
    reluLayer("Name","body_output")
    fullyConnectedLayer(2,"Name","output")
    tanhLayer("Name","tanh")
    regressionLayer("Name","regressionoutput")];
%%
regressionOptions = trainingOptions("sgdm", ...
    ValidationData = validationTable, ...
    MaxEpochs = 70, ...
    MiniBatchSize = 64, ...
    ValidationFrequency=10,...
    Plots = "training-progress",...
    LearnRateSchedule = "none",...
    InitialLearnRate=0.00001,...
    LearnRateDropPeriod = 5,...
    LearnRateDropFactor=0.2,...
    Verbose=0,...
    Shuffle="every-epoch",...
    GradientThreshold=1e5);
%%
net = trainNetwork(trainTable,layers,regressionOptions);

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
%imgTest = imgTest';
testTable = table(imgTest,YTest);
testSamples = table(imgTest);
%% 
ypred = predict(net,testSamples);

rmse = sqrt(mean((ypred-YTest).^2));
%%
figure(1);scatter(YTest(:,1),ypred(:,1));
figure(2);scatter(YTest(:,2),ypred(:,2));

diferense = sqrt((ypred(:,1)-YTest(:,1)).^2 + (ypred(:,2)-YTest(:,2)).^2);
x = find(rmse>0.5);
figure(3);scatter(ypred(:,1),ypred(:,2));
hold on
figure(3);scatter(ypred(x,1),ypred(x,2));
figure(4);boxplot(ypred(:,1),YTest(:,1));
figure(5);boxplot(ypred(:,2),YTest(:,2));
