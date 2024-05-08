%% MyoContextualBandit

classdef MyoContextualBandit < rl.env.MATLABEnvironment
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessar
        % y properties
        % Max radius of the area

        test_subject = 'Rebexis'
        Reward = [];
        counter = 0;
        init = false;
        data = [];
        sampleTime = 0.1;
        index_theta = 0;
        RewardForReachingGoal = 10;
        blue_marker_radius = 0.1; % Acceptable distance to the goal point
        MaxRo = 1; %unit circle radius
    end
    properties

        State = {[0 0];[0 0];zeros(40,40)}; % Goal_location(cartesian), act_location(cartesian), 8 channel EMG input

    end
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = 1;

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
        function this = MyoContextualBandit()
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
            
            IsDone = false;

            %reward
            dist = sqrt((act_X - goal_X)^2 + (act_Y- goal_Y)^2);
%             if dist <= this.blue_marker_radius
%                 Reward = this.RewardForReachingGoal;
%                 %IsDone = true;
% 
%             else
%                 Reward = -0.5*log(dist);
%             end

            Reward = -dist^2;
            this.Reward = Reward;
            % Check terminal condition

            %LoggedSignals = [Action,goal_location,Reward]


        end

        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)

            action_location0 = [0 0];% the curser is located at the origin
            if ~this.init
                getData(this);
                this.init = true;
            end

            this.counter = this.counter +1;
            disp(this.counter);
            img_name = this.data.Var1(this.counter);
            disp(string(img_name));
            ss = imread(string(img_name));
            imshow(ss)
            InitialObservation =  im2double(ss);
            goal_location = this.data.Var2(this.counter,:);
            disp(goal_location);
            this.State = {goal_location; action_location0; InitialObservation};

            notifyEnvUpdated(this);
        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods
        %Helper methods to create the environment
        
        function getData(this)
            name= this.test_subject;
            folder_name = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name);
            imds = imageDatastore(folder_name,"IncludeSubfolders",true,"LabelSource","foldernames");
            imdsTrain = shuffle(imds);

            %% Training labels
            labels = imdsTrain.Labels;
            x = [];
            y = [];
            i = 0;
            thetaTrain = deg2rad(double(string(labels)));
            for i = 1:length(thetaTrain)
                theta = thetaTrain(i);
                if theta == 0
                    xTemp = 0;
                    yTemp = 0;

                else
                    [xTemp,yTemp] = pol2cart(theta,1);
                    xTemp = round(xTemp);
                    yTemp = round(yTemp);
                end
                x = [x;xTemp];
                y = [y;yTemp];
                response = [x,y];
            end
            %%
            this.data = table(imdsTrain.Files,response);

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