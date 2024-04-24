
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
        index_theta = 0;
        Fs = 200; %Hz samplefrequency
        RewardForReachingGoal = 10;
        %RewardForCorrectQuadrant = 1;
        blue_marker_radius = 0.1; % Acceptable distance to the goal point
        MaxRo = 1; %unit circle radius
        PenaltyForOutOfLimits = -10;
        mvc = 30;
        Ts = 0.5;
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
            
            %get action
            action_location = Action;
            Observation = this.State{3};
            goal_location = this.State{1};
            goal_X = goal_location(1);
            goal_Y = goal_location(2);
            act_X = action_location(1);
            act_Y = action_location(2);
            %s = sqrt(act_Y^2 + act_X^2);

            
            this.State = {goal_location,action_location,Observation};
            notifyEnvUpdated(this);
            distMax = 1+sqrt(2); %largest possible distance. 
            IsDone = false;

            %reward
            dist = sqrt((act_X - goal_X)^2 + (act_Y- goal_Y)^2);
            if dist <= this.blue_marker_radius
                Reward = this.RewardForReachingGoal;
                %IsDone = true;

            else
                Reward = 0.1*((-sqrt(abs(dist-this.blue_marker_radius))+distMax)^3);
            end
            this.Reward = Reward
            % Check terminal condition
            
            %LoggedSignals = [Action,goal_location,Reward]


        end

        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            action_location0 = [0 0];% the curser is located at the origin
            goal_location = this.State{1};
            this.counter = this.counter + 1;
            if this.counter > 10
                this.counter = 1;
            end
            if this.counter == 1
                goal_location = getGoalLocation(this);
                this.State = {goal_location; action_location0; this.State};
                notifyEnvUpdated(this);
                txt = 'n';
                while txt == 'n'
                    prompt = "Are you ready? [y/n]";
                    txt = input(prompt,"s");
                    if isempty(txt)
                        txt = 'y';
                    end
                    if txt == 'y'
                        initMyo(this);

                    end
                end
                %this.counter = 1; 
            end
            
            disp(this.counter);
            img_name = sprintf('Sample%d.jpeg', this.counter);
            ss = imread(img_name);
            InitialObservation =  im2double(ss);
            this.State = {goal_location; action_location0; InitialObservation};

            notifyEnvUpdated(this);
        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods
        %Helper methods to create the environment
        function initMyo(this)
            emg = [];
            mm = MyoMex(); %mm = this.Myo;
            m1 = mm.myoData();
            
            confirm = false;
            while ~ confirm
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
                prompt = "Do you confirm? [y/n]";
                txt = input(prompt,"s");
                if isempty(txt)
                    txt = 'y';
                end
                if txt == 'y'
                    confirm = true;
                end
            end
            %img_matrix = emg(end-39:end,:);
            partision = [];
            for j = 1:8
                partision(:,j,:) = buffer(emg(:,j),40,10);
            end
            for i = 1:10
                img_name = sprintf('Sample%d.jpeg', i);
                %file_name = fullfile(folder_name + '\' + img_name);
                img_matrix = abs(partision(:,:,i));
                [img_envelope,~] = envelope(img_matrix,5);
                img_resize = repelem(img_envelope,1,5);
                imwrite(img_resize,img_name);
            end

%             Observation =  im2double(ss);
%             myoIsHere = Observation()


             mm.delete;
%             myoIsHere = emg(end-39:end,:);
        end
        function plotEMG(this)
        end
        function myoSample = getEmg(this)
            initMyo(this);
        end

        function goal_location = getGoalLocation(this)
            this.index_theta = this.index_theta + 1;
            if this.index_theta == 10
                this.index_theta = 1;
            end
            ro = [1,0.5,0];
            %theta = linspace(0,2*pi,9);
           theta = [0,pi,pi/2,2*pi,3*pi/2,pi/4,3*pi/4,7*pi/4,5*pi/4];
            %index_theta = randperm(9,1)
            if this.index_theta == 1
                index_ro = 3;
            else
                index_ro = randperm(1,1);
            end
            [x,y] = pol2cart(theta(this.index_theta),ro(index_ro));
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
                %disp('hera')

                
                
            end
        end
    end
end