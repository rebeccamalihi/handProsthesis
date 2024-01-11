classdef MyoEnvironment < rl.env.MATLABEnvironment
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties
        % Max radius of the area

        %myoStreaming = m1.isStreaming;
        test_subject = 'Rebecca'
        Reward = [];
        sampleTime = 0.25;
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
        State = {[0 0],[0 0],zeros(8,40)}; % Zeros(1800,8)}; % Goal_location(cartesian), act_location(cartesian), 8 channel EMG input
    end

    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false;

        % handle to Myo
        Myo;
        % handle to figure
        Figure;
    end

    %% Necessary Methods
    methods
        % Constructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = MyoEnvironment()
            % Initialize Observation settings
            ObservationInfo = rlNumericSpec([8 40]);
            ObservationInfo.Name = 'Observations';
            ObservationInfo.Description = 'EMG epoch 8 channels';

            % Initialize Action settings
            numAct = 2;
            ActionInfo = rlNumericSpec([numAct 1], LowerLimit = -1 , UpperLimit = 1);
            ActionInfo.Name = 'Action';
            ActionInfo.Description = 'X and Y cartesin values';

            %Initialize myo
            % mm = MyoMex();  
            % m1 = mm.myoData();
            %Myo = @m1;
            

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
            action_location0 = [0 0];
            emgSample = getEmgInfo(this);
            goal_location = getGoalLocation(this);
            InitialObservation = {goal_location, action_location0, emgSample};
            this.State = InitialObservation;
            notifyEnvUpdated(this);

        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods
        %Helper methods to create the environment
        function EMGSamples = getEmgSample(this)
            reb = [];
            this.Myo = MyoMex();
            m = this.Myo;
            e = m.myoData();
            pause(0.25)
            reb = e.emg_log;
            figure(1);plot(reb(end-39:end,:));
            %EMGSamples = e(end-39:end,:);
            delete(m);
        end

        function goal_location = getGoalLocation(this)
            goal_location = -1 + 2 * rand(1,2);
            %this.State(1) = goal_location;
        end


        function plot(this)
            % Initiate the visualization
            this.Figure = figure('Visible','on','HandleVisibility','off');
            ha = gca(this.figure);
            ha.XLimMode = 'manual';
            ha.YLimMode = 'manual';
            ha.XLim = [-1.5 1.5];
            ha.YLim = [-1.5 1.5];
            hold(ha,'on');
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
                unitcircle = 
                % draw the goal position area, target point and the
                % acceptable radius
                % % th_blue_marker = linspace(0,2*pi,30);
                % % [x_blue,y_blue] = pol2cart(th_blue_marker,this.blue_marker_radius);
                % % goal_center = getGoalLocation(this);
                % % xc_goal = goal_center(1);
                % % yc_goal = goal_center(2);
                % % x_goal = x_blue + xc_goal;
                % % y_goal = y_blue + yc_goal;
                % Action center
                action_center = this.state{2};
                % Refresh rendering in the figure window
                drawnow();
            end
        end
    end
end