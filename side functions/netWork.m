% function net = netWork(name)

clear all
name= "Sub4-half";
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
for i = 1:length(labels)
    a = double(string(labels(i)));
    r = rem(a,5);
    if r == 1
        ro = 0.5;
    else 
        ro = 1;
    end    
    theta = thetaTrain(i);
    if theta == 0
        xTemp = 0;
        yTemp = 0;

    else
        [xTemp,yTemp] = pol2cart(theta,ro);
%         xTemp = round(xTemp);
%         yTemp = round(yTemp);
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
    a = double(string(labelsVal(i)));
    r = rem(a,5);
    if r == 1
        ro = 0.5;
    else
        ro = 1;
    end
    theta = thetaVal(i);
    if theta == 0
        xTemp = 0;
        yTemp = 0;
    else
        [xTemp,yTemp] = pol2cart(theta,ro);
%         xTemp = round(xTemp);
%         yTemp = round(yTemp);
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
    a = double(string(labelsTest(i)));
    r = rem(a,5);
    if r == 1
        ro = 0.5;
    else 
        ro = 1;
    end   
    theta = thetaTest(i);
    if theta == 0
        xTemp = 0;
        yTemp = 0;
    else
        [xTemp,yTemp] = pol2cart(theta,ro);
%         xTemp = round(xTemp);
%         yTemp = round(yTemp);
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

%% network layers
mainPath = [
    imageInputLayer([56 56 1],"Name","imageinput",Normalization="none")
    convolution2dLayer([9 9],8,"Name","conv_1","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_1")
%     convolution2dLayer([3 3],8,"Name","conv_1_1","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_1_1")

    maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same")
    dropoutLayer(0.1,"Name","dropout_1")
% 
    convolution2dLayer([9 9],16,"Name","conv_2","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_2")
% %     convolution2dLayer([3 3],8,"Name","conv_2_1","Padding","same")
% %     leakyReluLayer(0.1,"Name","leakyrelu_2_1")
% % 
    maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same")
    dropoutLayer(0.1,"Name","dropout_2")
% % 
%     convolution2dLayer([9 9],16,"Name","conv_3","Padding","same")
%     leakyReluLayer(0.0,"Name","leakyrelu_3")
% %     convolution2dLayer([5 5],16,"Name","conv_3_1","Padding","same")
% %     leakyReluLayer(0.0,"Name","leakyrelu_3_1")
% % 
%     maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same")
%     dropoutLayer(0.1,"Name","dropout_3")
    
%     convolution2dLayer([3 3],16,"Name","conv_4","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_4")
%     convolution2dLayer([3 3],16,"Name","conv_4_1","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_4_1")
% 
%     maxPooling2dLayer([2 2],"Name","maxpool_4","Padding","same")
%     dropoutLayer(0.1,"Name","dropout_4")

%     convolution2dLayer([3 3],32,"Name","conv_5","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_5")
%     convolution2dLayer([3 3],32,"Name","conv_5_1","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_5_1")
% 
%     maxPooling2dLayer([2 2],"Name","maxpool_5","Padding","same")
%     dropoutLayer(0.1,"Name","dropout_5")

%     convolution2dLayer([3 3],32,"Name","conv_6","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_6")
%     convolution2dLayer([3 3],32,"Name","conv_6_1","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_6_1")

%     maxPooling2dLayer([2 2],"Name","maxpool_6","Padding","same")
%     dropoutLayer(0.1,"Name","dropout_6")
    fullyConnectedLayer(100,"Name","fc")
    leakyReluLayer(0.1,"Name","leakyrelu_7")
    fullyConnectedLayer(200,"Name","fc_1")
    leakyReluLayer(0.1,"Name","leakyrelu_8")
    fullyConnectedLayer(400,"Name","fc_2")
    leakyReluLayer(0.1,"Name","leakyrelu_9")
    fullyConnectedLayer(400,"Name","fc_3")
    leakyReluLayer(0.1,"Name","leakyrelu_10")
    fullyConnectedLayer(200,"Name","fc_4")
    leakyReluLayer(0.1,"Name","leakyrelu_11")
    fullyConnectedLayer(100,"Name","fc_5")
    leakyReluLayer(0.1,"Name","leakyrelu_12")
    ];

regressionPath = [
    fullyConnectedLayer(2,"Name","fc_reg")
    leakyReluLayer(0.1,"Name","leakyrelu_reg")
    tanhLayer("Name","tanh")
    scalingLayer("Name","scaling")
    regressionLayer("Name","regressionoutput")];

regressionNet = layerGraph();
regressionNet = addLayers(regressionNet,mainPath);
regressionNet = addLayers(regressionNet,regressionPath);
regressionNet = connectLayers(regressionNet,"leakyrelu_12","fc_reg");
%plot(regressionNet)
%analyzeNetwork(regressionNet)
%% regression network
ops = trainingOptions("sgdm",...
    ValidationData = validationTable,...
    MaxEpochs = 50,... 
    miniBatchSize = 32,...
    ValidationFrequency=64, ...
    Plots = "training-progress",...
    InitialLearnRate=0.005, ...
    Verbose = false, ...
    Shuffle="every-epoch", ...
    OutputNetwork="best-validation", ...
    GradientThreshold=1e5);



net = trainNetwork(trainTable,regressionNet,ops);
ypred = predict(net,testSamples);
rmse = sqrt(mean((ypred-YTest).^2));
%%
% x_f = 0;
% y_f = 0;
% 
% for i= 1:410
%     act2 = getAction(agent_Trained_1,testSamples.imgTest{i,1});
%     x = 1*act2{1}(1);
%     y = 1*act2{1}(2);
%     x_f = [x_f,x];
%     y_f = [y_f,y];
% end
figure(1);scatter(YTest(:,1),ypred(:,1));
figure(2);scatter(YTest(:,2),ypred(:,2));
% figure(3);scatter(YTest(:,1),x_f);
% figure(3);scatter(YTest(:,2),y_f);


diference = sqrt((ypred(:,1)-YTest(:,1)).^2 + (ypred(:,2)-YTest(:,2)).^2);
x = find(diference>0.3);
figure(3);scatter(ypred(:,1),ypred(:,2)); 
hold on
figure(3);scatter(ypred(x,1),ypred(x,2));
figure(4);boxplot(ypred(:,1),YTest(:,1));
figure(5);boxplot(ypred(:,2),YTest(:,2));
l = double(string(imdsTest.Labels)); % test lables(double)
boxplot(diference,l);
save('Sub4\Sub4_net17p.mat','net');
%
save('Sub4\test_net17p.mat',"YTest","ypred")


% end