classdef MyoEnvironment < rl.env.MATLABEnvironment
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties
        % Max radius of the area

        %myoStreaming = m1.isStreaming;
        test_subject = 'Rebecca'
        Reward = [];
        sampleTime = 0.25;
        Fs = 200; %Hz samplefrequency
        % Index_amount = 20;
        % Counter = 1;
        RewardForReachingGoal = 10;
        RewardForCorrectQuadrant = 1;
        blue_marker_radius = 0.08; % Acceptable distance to the goal point
        MaxRo = 1; %unit circle radius
        PenaltyForOutOfLimits = -10;
        PenaltyForNotReachingGoal = -1;%penalty for not reaching the goal for every try
        StepThreshold = 10;% the number of steps to fail the episode
    end
    properties
        State = {[0 0],[0 0],zeros(40,40)}; % Zeros(1800,8)}; % Goal_location(cartesian), act_location(cartesian), 8 channel EMG input
    end
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false;

        % handle to Myo
        Myo;
        % handle to figure
        Figure;
        EmgDisplay;
    end

    %% Necessary Methods
    methods
        % Constructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = MyoEnvironment()
            % Initialize Observation settings
            ObservationInfo = rlNumericSpec([40 40]);
            ObservationInfo.Name = 'Observations';
            ObservationInfo.Description = 'EMG epoch 8 channels';

            % Initialize Action settings
            numAct = 2;
            ActionInfo = rlNumericSpec([numAct 1], LowerLimit = -1 , UpperLimit = 1);
            ActionInfo.Name = 'Action';
            ActionInfo.Description = 'X and Y cartesin values';

            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);

            %updateActionInfo(this);
        end

        % Apply system dynamics and simulates the environment with the
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];

            %get action
            action_location = Action;
            %Observation = this.State{3};% the emg sample
            goal_location = this.State{1};
            goal_X = goal_location(1);
            goal_Y = goal_location(2);
            act_X = action_location(1);
            act_Y = action_location(2);

            % Update system states
            %this.State = {goal_location, act_location, Observation};

            %reward
            R = abs(2 - sqrt((act_x - goal_x)^2 + (act_y - goal_y)^2));
            if R <= this.blue_marker_radius
                Reward = this.RewardForReachingGoal;

            else
                Reward = R;

            end

            this.Reward = Reward;
            % Check terminal condition
            IsDone = R <= this.blue_marker_radius || R > 2;
            this.IsDone = IsDone;
            notifyEnvUpdated(this);
        end

        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            action_location0 = [0 0];% the curser is located at the origin
            %emgSample = getEmgInfo(this);
            goal_location = getGoalLocation(this);
            InitialObservation = {goal_location, action_location0, emgSample};
            this.State = InitialObservation;
            notifyEnvUpdated(this);
        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods
        %Helper methods to create the environment
        function myoIsHere = initMyo(this)
            % emg = []
            this.Myo = MyoMex();
            m = this.Myo;
            %e = m.myoData();
            pause(1);
            %emg = e.emg_log;
            myoIsHere = m;
        end
   
        function EMGSamples = getEmgSample(this,m)
            e = m.myoData();
            if e.isStreaming == 1
                emg = e.emg_log;
                %figure(1);plot(reb(end-39:end,:));
                EMGSamples = abs(emg(end-39:end,:));
                disp('here')
            end
            %delete(m);
            function clearMyo(m)
                ea = m.myoData();
                if ea.isStreaming == 1
                    delete(m);
                end
            end
        end
        function emgsample = getEmgPower(this)
            m = initMyo(this);
            this.EmgDisplay = uifigure('Visible','on','HandleVisibility','off');
            emgCg = uigauge(this.EmgDisplay,"Position",[100 60 350 350]);
            while 1
                sigTemp = getEmgSample(this,m);
                meanF = signalTimeFeatureExtractor("Mean", true, 'SampleRate', this.Fs);
                meanFDS = arrayDatastore(sigTemp,"IterationDimension",2);
                meanFDS = transform(meanFDS,@(x)meanF.extract(x{:}));
                meanFeatures = readall(meanFDS,"UseParallel",true);
                emgPower= max(meanFeatures);
                emgCg.Value = 100 * emgPower;
                % Refresh rendering in the figure window
                drawnow();
                if emgPower > 8
                    sampleIsTaken = sigTemp;
                    img_resize = repelem(sampleIsTaken,1,5);
                    emgsample = img_resize;
                    imwrite(img_resize,'sample.jpeg');
                    imshow('sample.jpeg');
                    break
                end
                pause(0.3);
            end
            clearMyo(m);
        end

        function goal_location = getGoalLocation(this)
            rand_goal_location = 1.1;
            while rand_goal_location > 1
                rand_goal = -1 + 2 * rand(1,2);
                rand_goal_location = sqrt(rand_goal(1)^2+rand_goal(2)^2);
            end
            goal_location = rand_goal;
        end

        function plot(this)
            % Initiate the visualization
            this.Figure = figure('Visible','on','HandleVisibility','off');
            ha = gca(this.Figure);
            ha.XLimMode = 'manual';
            ha.YLimMode = 'manual';
            ha.XLim = [-1.5 1.5];
            ha.YLim = [-1.5 1.5];
            hold(ha,'on');
            % Initiate the emg display


            envUpdatedCallback(this)
        end
    end
    %
    methods (Access = protected)
        % (optional) update visualization everytime the environment is updated
        % (notifyEnvUpdated is called)
        function envUpdatedCallback(this)
            if ~isempty(this.Figure) && isvalid(this.Figure)
                % Set visualization figure as the current figure
                ha = gca(this.Figure);
                % draw the unit circle
                th_red_marker = linspace(0,2*pi,60);
                [x_unit,y_unit] = pol2cart(th_red_marker,this.MaxRo);
                unitcircle = plot(ha,x_unit,y_unit,"Color",'r','LineStyle','--');
                unitcircle.LineWidth  = 2;
                % draw x and y axes
                xLine_marker = linspace(-1.1,1.1,5);
                xAxis = plot(ha,xLine_marker,zeros(5),"Color",'k',"LineWidth",2);
                yAxis = plot(ha,zeros(5),xLine_marker,"Color",'k',"LineWidth",2);
                % draw the goal position area, target point and the
                % acceptable radius
                th_blue_marker = linspace(0,2*pi,30);
                [x_blue,y_blue] = pol2cart(th_blue_marker,this.blue_marker_radius);
                goal_center = getGoalLocation(this);
                xc_goal = goal_center(1);
                yc_goal = goal_center(2);
                x_goal = x_blue + xc_goal;
                y_goal = y_blue + yc_goal;
                goalArea = plot(ha,x_goal,y_goal,"Color",'b');

                action_center = this.State{2};
                x_action = 0.5;%action_center(1);
                y_action = 0.6;%action_center(2);
                emgSample = 90;%*this.getEmgSample;
                action_point = scatter(ha,x_action,y_action,"green","g",'Marker','*',"LineWidth",5);


            end
        end
    end
end