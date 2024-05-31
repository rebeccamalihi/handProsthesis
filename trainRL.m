env = MyoEnvironment_offline; % also  MyoEnvironment_offline
obsInfo = getObservationInfo(env);
actInfo= getActionInfo(env);

plot(env);
%%
load('C:\Users\lab-admin\Desktop\Rebecca\Sub4\Sub4_net9p.mat');
%% actor 
actorNetwork = layerGraph(net);
%actorNetwork = removeLayers(actorNetwork,"regressionoutput"); %removeLayers(actorNetwork,["scaling","regressionoutput","leakyrelu_8"]);
%actorNetwork = connectLayers(actorNetwork,"fc_3","tanh");


figure(3)
plot(actorNetwork)
analyzeNetwork(actorNetwork)
%%
actor = rlContinuousDeterministicActor(actorNetwork,obsInfo,actInfo,ObservationInputNames = "imageinput");

%% critic
mainPath = [
    imageInputLayer([56 56 1],"Name","imageinput",Normalization="none")
    convolution2dLayer([9 9],8,"Name","conv_1","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_1")
%     convolution2dLayer([3 3],8,"Name","conv_1_1","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_1_1")

    maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same")
    dropoutLayer(0.1,"Name","dropout_1")

    convolution2dLayer([9 9],16,"Name","conv_2","Padding","same")
    leakyReluLayer(0.1,"Name","leakyrelu_2")
%     convolution2dLayer([3 3],16,"Name","conv_2_1","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_2_1")

    maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same")
    dropoutLayer(0.1,"Name","dropout_2")
% 
%     convolution2dLayer([3 3],32,"Name","conv_3","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_3")
%     convolution2dLayer([3 3],32,"Name","conv_3_1","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_3_1")
% 
%     maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same")
%     dropoutLayer(0.1,"Name","dropout_3_1")
%     
%     convolution2dLayer([3 3],32,"Name","conv_4","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_4")
%     convolution2dLayer([3 3],32,"Name","conv_4_1","Padding","same")
%     leakyReluLayer(0.1,"Name","leakyrelu_4_1")

%     maxPooling2dLayer([2 2],"Name","maxpool_4","Padding","same")
%     dropoutLayer(0.1,"Name","dropout_4")
    fullyConnectedLayer(100,"Name","fc")
    leakyReluLayer(0.1,"Name","leakyrelu_3")
    fullyConnectedLayer(200,"Name","fc_1")
    leakyReluLayer(0.1,"Name","leakyrelu_4")
    fullyConnectedLayer(400,"Name","fc_2")
    leakyReluLayer(0.1,"Name","leakyrelu_5")
    fullyConnectedLayer(400,"Name","fc_3")
    leakyReluLayer(0.1,"Name","leakyrelu_6")
    fullyConnectedLayer(200,"Name","fc_4")
    leakyReluLayer(0.1,"Name","leakyrelu_7")
    fullyConnectedLayer(100,"Name","fc_5")
    leakyReluLayer(0.1,"Name","leakyrelu_8")
    fullyConnectedLayer(1,"Name","fc_6")];
action_path = [
    featureInputLayer(2,"Name","actinLyr")
    fullyConnectedLayer(100,"Name","fc_7")
    concatenationLayer(1,2,"Name","cct")
    ];
criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,mainPath);
% plot(criticNetwork);
criticNetwork = disconnectLayers(criticNetwork,"fc","leakyrelu_3");
criticNetwork = addLayers(criticNetwork,action_path);
% plot(criticNetwork);
criticNetwork = connectLayers(criticNetwork,"fc","cct/in2");
%criticNetwork = addLayers(criticNetwork,action_path);
% plot(criticNetwork);
criticNetwork = connectLayers(criticNetwork,"cct","leakyrelu_3");
figure(2);
plot(criticNetwork);
criticNetwork = dlnetwork(criticNetwork);

criticNetwork = initialize(criticNetwork);
analyzeNetwork(criticNetwork)
%% 
critic = rlQValueFunction(criticNetwork,obsInfo,actInfo,"ObservationInputNames", "imageinput","ActionInputNames","actinLyr");
%% actor options
actorOptions = rlOptimizerOptions(...
    Optimizer = "sgdm",...
    LearnRate = 1e-04,...
    GradientThreshold = 1e5);
%% critic options
criticOptions = rlOptimizerOptions(...
    Optimizer = "sgdm",...
    LearnRate = 5e-3,...
    GradientThreshold = 1e5);
%% agent
agentOptions = rlDDPGAgentOptions(...
    SampleTime=env.Ts,...
    TargetSmoothFactor = 1e-3,...
    ExperienceBufferLength = 1e6,...
    DiscountFactor = 0.99,...
    MiniBatchSize = 50);

%% TD3 options
% agentOptions.ExplorationModel.StandardDeviation = 0.1;
% agentOptions.ExplorationModel.StandardDeviationDecayRate = 1e-4;
% agentOptions.ExplorationModel = rl.option.OrnsteinUhlenbeckActionNoise;
% agentOptions.ExplorationModel.StandardDeviation = 0.1;
%% ddpg options
% agentOptions.NoiseOptions.StandardDeviation = 0.3;
% agentOptions.NoiseOptions.StandardDeviationDecayRate = 1e-6;
% agentOptions.NoiseOptions.StandardDeviationMin = 0.1;
% agentOptions.CriticOptimizerOptions = criticOptions;
% agentOptions.ActorOptimizerOptions = actorOptions;
 %% Creat agent
 agent = rlDDPGAgent(actor,critic,agentOptions);
%% training options
trainingOptions = rlTrainingOptions( ...
    MaxEpisodes = 500,...
    MaxStepsPerEpisode = 1, ...
    Plots = "training-progress",...
    StopTrainingCriteria = "EpisodeCount",...
    StopTrainingValue = 500);
%% evaluator
%evaluator = rlEvaluator;
%% train
%agent_trained = train(agent,env,trainingOptions);







