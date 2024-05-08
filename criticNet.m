%%train critic network
% clear all
name= "Rebexis";
imds = imageDatastore(name,"IncludeSubfolders",true,"LabelSource","foldernames");
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
for i = 1:length(imgSamples)
    ss = imread(imgSamples{i});
    imgSamples{i} = im2double(ss);
end
%% Validation dataset
imgValSamples = {};
for j =1:length(imdsVal.Labels)
    filename = imdsVal.Files{j};
    imgValSamples{j} = filename;
end
imgValSamples = imgValSamples';
for i = 1:length(imgValSamples)
    ss = imread(imgValSamples{i});
    imgValSamples{i} = im2double(ss);
end

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
%%
for k =1:length(imdsTest.Labels)
    filename = imdsTest.Files{k};
    imgTest{k} = filename;
end

%%
imgTest = imgTest';
for i = 1:length(imgTest)
    ss = imread(imgTest{i});
    imgTest{i} = im2double(ss);
end
testTable = table(imgTest,YTest);
testSamples = table(imgTest);
%% critic layers
mainPath = [
    imageInputLayer([40 40 1],"Name","imageinput",Normalization="none")
    convolution2dLayer([3 3],8,"Name","conv_1","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_1")
    convolution2dLayer([3 3],8,"Name","conv_1_1","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_1_1")

    maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same")
    dropoutLayer(0.1,"Name","dropout_1")

    convolution2dLayer([3 3],16,"Name","conv_2","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_2")
    convolution2dLayer([3 3],16,"Name","conv_2_1","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_2_1")

    maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same")
    dropoutLayer(0.1,"Name","dropout_2_1")

    convolution2dLayer([3 3],32,"Name","conv_3","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_3")
    convolution2dLayer([3 3],32,"Name","conv_3_1","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_3_1")

    maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same")
    dropoutLayer(0.1,"Name","dropout_3_1")
    
    convolution2dLayer([3 3],32,"Name","conv_4","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_4")
    convolution2dLayer([3 3],32,"Name","conv_4_1","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_4_1")

    maxPooling2dLayer([2 2],"Name","maxpool_4","Padding","same")
    dropoutLayer(0.1,"Name","dropout_4")
    fullyConnectedLayer(256,"Name","fc")
    leakyReluLayer(0.1,"Name","leakyrelu_5")
    fullyConnectedLayer(256,"Name","fc_1")
    leakyReluLayer(0.1,"Name","leakyrelu_6")
    fullyConnectedLayer(128,"Name","fc_2")
    leakyReluLayer(0.1,"Name","leakyrelu_7")
    fullyConnectedLayer(1,"Name","fc_3")
    regressionLayer("Name","regcritic")];
action_path = [
    featureInputLayer(2,"Name","actinLyr")
    fullyConnectedLayer(128,"Name","fc_4")
    concatenationLayer(1,2,"Name","cct")
    ];
criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,mainPath);
plot(criticNetwork);
criticNetwork = disconnectLayers(criticNetwork,"fc","leakyrelu_5")
criticNetwork = addLayers(criticNetwork,action_path);
plot(criticNetwork);
criticNetwork = connectLayers(criticNetwork,"fc","cct/in2");
%criticNetwork = addLayers(criticNetwork,action_path);
plot(criticNetwork);
criticNetwork = connectLayers(criticNetwork,"cct","leakyrelu_5");
plot(criticNetwork);
%%

regressionOptions = trainingOptions("sgdm", ...
    ValidationData = validationTable, ...
    MaxEpochs = 50, ...
    MiniBatchSize = 64, ...
    ValidationFrequency=20, ...
    Plots = "training-progress", ...
    InitialLearnRate=0.001, ...
    Verbose=0, ...
    Shuffle="every-epoch", ...
    OutputNetwork="best-validation", ...
    GradientThreshold=1e5);
%% 
