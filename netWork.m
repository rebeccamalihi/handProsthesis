%function netWork(name)
imds = imageDatastore("Rebecka\","IncludeSubfolders",true,"LabelSource","foldernames");
imds.Labels = double(imds.Labels);
imds = shuffle(imds);
[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.7,0.15,0.15,"randomized");
imdsTrain = transform(imdsTrain, @(x) rescale(x));
imdsVal = transform(imdsVal, @(x) rescale(x));
imdsTest = transform(imdsTest, @(x) rescale(x));
layers = [
    imageInputLayer([40 40 1],"Name","imageinput")
    convolution2dLayer([3 3],32,"Name","conv","Padding","same")
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
    %fullyConnectedLayer(2,"Name","fc_3")
    fullyConnectedLayer(2,"Name","fc_5")
    scalingLayer("Name","scaling")
    regressionLayer("Name","regressionoutput")];


options = trainingOptions("adam", ...
    MaxEpochs=10, ...
    MiniBatchSize=32, ...
    Plots="training-progress",...
    InitialLearnRate=0.002,...
    Verbose=0,...
    Shuffle="every-epoch",...
    GradientThreshold=1e6);

%end