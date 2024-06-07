%% trained actor and critic
env = MyoEnvironment;
obsInfo = getObservationInfo(env);
actInfo= getActionInfo(env);
plot(env);
%% actor 
actorNetwork = layerGraph();
actorNetwork = addLayers(actorNetwork,net.Layers);
actorNetwork = removeLayers(actorNetwork,"regressionoutput");
actor = rlContinuousDeterministicActor(actorNetwork,obsInfo,actInfo,ObservationInputNames = "imageinput");
figure
plot(actorNetwork);
analyzeNetwork(actorNetwork);
%% critic


act_path = [
    featureInputLayer(2,"Name","actinLyr")
    fullyConnectedLayer(256,"Name","fc_2")];
criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,img_path_actor);
criticNetwork = addLayers(criticNetwork,act_path);
criticNetwork = connectLayers(criticNetwork,"fc_2","addition/in2");

plot(criticNetwork);
criticNetwork = dlnetwork(criticNetwork);

criticNetwork = initialize(criticNetwork);
critic = rlQValueFunction(criticNetwork,...
    obsInfo,actInfo,...
    ObservationInputNames = "imageinput", ...
    ActionInputNames = "actinLyr");
%% actor options
actorOptions = rlOptimizerOptions(...
    LearnRate = 1e-04,...
    GradientThreshold = 1);
%% critic options
criticOptions = rlOptimizerOptions(...
    LearnRate = 1e-3,...
    GradientThreshold = 1);
%% agent
agentOptions = rlDDPGAgentOptions(...
    SampleTime=env.Ts,...
    TargetSmoothFactor = 1e-3,...
    ExperienceBufferLength = 1e6,...
    DiscountFactor = 0.99,...
    MiniBatchSize = 64);
agentOptions.NoiseOptions.StandardDeviation = 0.6;
agentOptions.NoiseOptions.StandardDeviationDecayRate = 1e-6;
agentOptions.NoiseOptions.StandardDeviationMin = 0.1;
agentOptions.CriticOptimizerOptions = criticOptions;
agentOptions.ActorOptimizerOptions = actorOptions;
 %% train agent
 agent = rlDDPGAgent(actor,critic,agentOptions);




