env = MyoEnvironment;
obsInfo = getObservationInfo(env);
actInfo= getActionInfo(env);
% layers = [
%     imageInputLayer(obsInfo,"Name","imageinput")
%     convolution2dLayer([3 3],16,"Name","conv","Padding","same")
%     leakyReluLayer(0.01,"Name","leakyrelu")
%     maxPooling2dLayer([5 5],"Name","maxpool","Padding","same")
%     fullyConnectedLayer(16,"Name","fc")
%     convolution2dLayer([3 3],16,"Name","conv_1","Padding","same")
%     leakyReluLayer(0.01,"Name","leakyrelu_1")
%     maxPooling2dLayer([5 5],"Name","maxpool_1","Padding","same")
%     fullyConnectedLayer(32,"Name","fc_1")
%     convolution2dLayer([3 3],32,"Name","conv_2","Padding","same")
%     leakyReluLayer(0.01,"Name","leakyrelu_2")
%     maxPooling2dLayer([5 5],"Name","maxpool_2","Padding","same")
%     fullyConnectedLayer(32,"Name","fc_2")
%     convolution2dLayer([3 3],32,"Name","conv_3","Padding","same")
%     leakyReluLayer(0.01,"Name","leakyrelu_3")
%     maxPooling2dLayer([5 5],"Name","maxpool_3","Padding","same")
%     fullyConnectedLayer(20,"Name","fc_3")
%     fullyConnectedLayer(2,"Name","fc_4")
%     scalingLayer("Name","scaling")];