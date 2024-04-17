
classdef MyoEnvironment < rl.env.MATLABEnvironment
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessar 
        % y properties
        % Max radius of the area

        test_subject = 'Rebecca'
        Reward = [];
        counter = 0;
        sampleTime = 0.25;
        Fs = 200; %Hz samplefrequency
        RewardForReachingGoal = 10;
        %RewardForCorrectQuadrant = 1;
        blue_marker_radius = 0.08; % Acceptable distance to the goal point
        MaxRo = 1; %unit circle radius
        PenaltyForOutOfLimits = -20;
        mvc = 30;
        Ts = 1;
        %PenaltyForNotReachingGoal = -1;%penalty for not reaching the goal for every try
        %StepThreshold = 10;% the number of steps to fail the episode
    end
    properties
        
        State = {[0 0];[0 0];zeros(40,40)}; % Goal_location(cartesian), act_location(cartesian), 8 channel EMG input
      
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
            ObservationInfo = rlNumericSpec([40 40 1],'LowerLimit',0,'UpperLimit',1);
            ObservationInfo.Name = 'Observations';
            ObservationInfo.Description = '40 * 40 * 1   8 channels EMG';

            % Initialize Action settings
            numAct = 2;
            ActionInfo = rlNumericSpec([numAct 1], LowerLimit = -1 , UpperLimit = 1);
            ActionInfo.Name = 'Actionsyx';


            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);
            %updateActionInfo(this);
        end

        % Apply system dynamics and simulates the environment with the
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];
            this.counter = this.counter+1;
            %get action
            action_location = Action;
            Observation = this.State{3};
            goal_location = this.State{1};
            goal_X = goal_location(1);
            goal_Y = goal_location(2);
            act_X = action_location(1);
            act_Y = action_location(2);
            s = sqrt(act_Y^2 + act_X^2);
            this.State = {goal_location,action_location,Observation};
            notifyEnvUpdated(this);
            IsDone = false;
            if s > 1
                Reward = this.PenaltyForOutOfLimits;
                %IsDone = true;
            else 
                %reward
                R = sqrt((act_X - goal_X)^2 + (act_Y- goal_Y)^2);
                if R <= this.blue_marker_radius
                    Reward = this.RewardForReachingGoal;
                    %IsDone = true;
                else
                    Reward = abs(2 - R);
                end
            end
            this.Reward = Reward;
            % Check terminal condition
            
            


        end

        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            action_location0 = [0 0];% the curser is located at the origin
            goal_location = getGoalLocation(this)
            this.State = {goal_location; action_location0; this.State};
            notifyEnvUpdated(this);
            prompt = "Are you ready? [y/n]";
            txt = input(prompt,"s");
            if isempty(txt)
                txt = 'y';
            end
            if txt == 'y'
                InitialObservation = initMyo(this);
            end
            this.State = {goal_location; action_location0; InitialObservation};

        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods
        %Helper methods to create the environment
        function myoIsHere = initMyo(this)
            emg = [];
            mm = MyoMex(); %mm = this.Myo;
            m1 = mm.myoData();
            pause(3);
            emg = m1.emg_log(end-399:end,:);
            figure(3);
            figure(3);subplot(8,1,1);plot(emg(:,1));ylim([-1, 1]);
            figure(3);subplot(8,1,2);plot(emg(:,2));ylim([-1, 1]);
            figure(3);subplot(8,1,3);plot(emg(:,3));ylim([-1, 1]);
            figure(3);subplot(8,1,4);plot(emg(:,4));ylim([-1, 1]);
            figure(3);subplot(8,1,5);plot(emg(:,5));ylim([-1, 1]);
            figure(3);subplot(8,1,6);plot(emg(:,6));ylim([-1, 1]);
            figure(3);subplot(8,1,7);plot(emg(:,7));ylim([-1, 1]);
            figure(3);subplot(8,1,8);plot(emg(:,8));ylim([-1, 1]);
            img_matrix = emg(end-39:end,:);
            img_resize = repelem(img_matrix,1,5);
            file = "EMGsample";
            imwrite(img_resize,file,"jpeg");
            ss = imread("EMGsample");
            InitialObservation =  im2double(ss);
            myoIsHere = InitialObservation;


             mm.delete;
%             myoIsHere = emg(end-39:end,:);
        end
        function plotEMG(this)
        end
        function myoSample = getEmg(this)
            initMyo(this);
        end

        function goal_location = getGoalLocation(this)
            ro = [0,0.5,1];
            theta = linspace(0,2*pi,5);
            index_ro = randperm(3,1);
            index_theta = randperm(5,1);
            [x,y] = pol2cart(theta(index_theta),ro(index_ro));
            goal_location = [x y];

        end

        function plot(this)
            % Initiate the visualization
            this.Figure = figure('Visible','on','HandleVisibility','off');
            ha = gca(this.Figure);
            ha.XLimMode = 'manual';
            ha.YLimMode = 'manual';
            ha.XLim = [-1.5 1.5];
            ha.YLim = [-1.5 1.5];
            
            %draw the unit circle
            th_red_marker = linspace(0,2*pi,60);
            [x_unit,y_unit] = pol2cart(th_red_marker,this.MaxRo);
            unitcircle = plot(ha,x_unit,y_unit,"Color",'r','LineStyle','--');
            unitcircle.LineWidth  = 2;
            % draw x and y axes
            xline(ha,0,'--r');
            yline(ha,0,'--r');
            hold(ha,'on');
            envUpdatedCallback(this);
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
                goalArea = findobj(ha,'Tag','goalArea');
                action_point = findobj(ha,'Tag','action_point');
                delete(goalArea);
                delete(action_point);
                % draw the goal position area, target point and the
                % acceptable radius
                th_blue_marker = linspace(0,2*pi,30);
                [x_blue,y_blue] = pol2cart(th_blue_marker,this.blue_marker_radius);
                goal_center = this.State{1};
                xc_goal = goal_center(1);
                yc_goal = goal_center(2);
                x_goal = x_blue + xc_goal;
                y_goal = y_blue + yc_goal;

                goalArea = plot(ha,x_goal,y_goal,"Color",'b');drawnow;
                goalArea.Tag = 'goalArea';
              
                action_center = this.State{2};
                x_action = action_center(1);
                y_action = action_center(2);
                action_point = scatter(ha,x_action,y_action,"green","g",'Marker','*',"LineWidth",5);
                action_point.Tag = 'action_point';
                drawnow;
                disp('hera')
                
                
            end
        end
    end
end