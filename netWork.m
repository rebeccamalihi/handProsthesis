%function netWork(name)

%%
% initialision of varibales
imds = imageDatastore("Rebecka\","IncludeSubfolders",true,"LabelSource","foldernames");
imds.Labels = double(imds.Labels);
imds.Labels = 90 * imds.Labels;
imds = shuffle(imds);
[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.7,0.15,0.15,"randomized");
% imdsTrain = transform(imdsTrain, @(x) rescale(x));
% imdsVal = transform(imdsVal, @(x) rescale(x));
% imdsTest = transform(imdsTest, @(x) rescale(x));
imgSamples = {};
YTrain = {};
%%
for k =1:length(imdsTrain.Labels)
    filename = imdsTrain.Files{k};
    %img = imread(filename);
    %imgMat = im2double(img);
    %imgSamples(:,:,k) = imgMat;
    imgSamples{k} = filename;
end
imgSamples = imgSamples';

labels = imdsTrain.Labels;
x = [];
y = [];
for i = 1:length(labels)
    [xTemp,yTemp] = pol2cart(labels(i),1);
    x = [x;xTemp];
    y = [y;yTemp];
end
response = x;%table(x,y);
response (:,:,2)= y; 
for l = 1:length(labels)
    YTrain{l} = response(l,:,:);
end


%%
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
    %scalingLayer("Name","scaling")
    regressionLayer("Name","regressionoutput")];


for j =1:length(imdsVal.Labels)
    filename = imdsVal.Files{j};
    imgdata2 = imread(filename);
    imgdata2Mat = im2double(imgdata2);
    imgValSamples(:,:,j) = imgdata2Mat;
end
labelsVal = imdsVal.Labels;
x = [];
y = [];
for i = 1:length(labelsVal)
    [xTemp,yTemp] = pol2cart(labels(i),1);
    x = [x;xTemp];
    y = [y;yTemp];
end
responseVal = [x,y];%table(x,y);
 %'ValidationData',{imgValSamples,responseVal}, ...
options = trainingOptions("adam", ...
    MaxEpochs = 120, ...
    MiniBatchSize = 32, ...
    Plots = "training-progress",...
    InitialLearnRate=0.003,...
    Verbose=0,...
    Shuffle="every-epoch",...
    GradientThreshold=1e4);
%end

YTrain = YTrain';
lbltables = table(imgSamples,YTrain);
net = trainNetwork(lbltables,layers,options);
%net = fitrnet(imgSamples,response(:,1));

%net = trainNetwork(imgSamples,YTrain,layers,options);
ypred = predict(net,imdsTrain);

rmse = sqrt(mean(ypred-))



