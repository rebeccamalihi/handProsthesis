%regression test
% 
% function pureRegressionTest
imds = imageDatastore("Rebecka\","IncludeSubfolders",true,"LabelSource","foldernames");
imds.Labels = double(imds.Labels);
imds.Labels = 90 * imds.Labels;
imds = shuffle(imds);
[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.7,0.15,0.15,"randomized");
imgSamples = [];
for k =1:124
    filename = imdsTrain.Files{k};
    img = imread(filename);
    %imgMat = im2double(img);
    imgSamples{k} = filename;%imgMat;
   
end
imgSamples = imgSamples';
labels = imdsTrain.Labels;
x = [];
y = [];
for i = 1:length(labels)
    [xTemp,yTemp] = pol2cart(labels(i),1);
    x = [x;xTemp];
    y = [y;yTemp];
    %response{i} = resonse_temp(i,:,:); 
end
response_temp = x;
response_temp(:,:,2) = y;
response = {};
for j = 1:length(response_temp)
    response{j} = response_temp(j,:,:);
end

response = response';
data_table = table(imgSamples,response);

%regTable = table(imgSamples,x,y);
%response = table(x,y);
%%
%options

options = trainingOptions("adam", ...
    MaxEpochs = 100, ...
    MiniBatchSize = 64, ...
    Plots = "training-progress",...
    InitialLearnRate=0.004,...
    Verbose=0,...
    Shuffle="every-epoch",...
    GradientThreshold=1e6);
%% 
%layers
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

net = trainNetwork(data_table, layers,options);
ypred = predict(net,imdsTest); 


% end
xTest = [];
yTest = [];
xTemp = [];
yTemp = [];
i = 0;
for i = 1:length(imdsTest.Labels)
    [xTemp,yTemp] = pol2cart(labels(i),1);
    xTest = [xTest;xTemp];
    yTest = [yTest;yTemp];
end
x = 0;
y = 0;
x = linspace(-1,1,50);
y=x;
figure(1);
plot(x,y);
hold on
scatter(ypred(:,1),yTest);
hold off
figure(2)
plot(x,y);
hold on 
scatter(ypred(:,2),yTest);
hold off


%[trainedModel, validationRMSE] = trainRegressionModel()