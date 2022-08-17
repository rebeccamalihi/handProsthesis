classdef MyoEnvironment < rl.env.MATLABEnvironment  
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties    
        %max radius of the area

        
        %test_subject = 'rebecca';
        %index0 = 1;
        Reward = [];
        index_amount = 20;
        counter = 1;
        RewardForReachingGoal = 10;
        blue_marker_radius = 0.08;   

    end
    
    properties
          State = {[0 0],[0 0],zeros(1800,8)}; %goal_location,act_location,8 channel EMG epoch 
    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = 0;
        
        %handle to figure
        Figure;
    end

    %% Necessary Methods
    methods              
        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = MyoEnvironment()
            % Initialize Observation settings
            ObservationInfo = rlNumericSpec([1800 8]);
            ObservationInfo.Name = 'Observations';      
            ObservationInfo.Description = 'EMG epoch 8 channels';
            
            % Initialize Action settings   
            theta_act = linspace(0,359,360);
            acts = {[0 0]};
            for i= 1:4
                for j = 1:360
                    acts(length(acts)+1) = {[theta_act(j) i*0.25]};
                    %acts_vect(length(acts_vec)+1) = 
                end
            end


            ActionInfo = rlFiniteSetSpec(acts);
            ActionInfo.Name = 'Action';
            ActionInfo.Description = 'theta,ro';

            
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);


        end
        
        % Apply system dynamics and simulates the environment with the 
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];

           
            Observation = this.State{3};
            goal_location = this.State{1};
            goal_theta = goal_location(2);
            goal_ro = goal_location(1);
            [goal_x,goal_y] = pol2cart(goal_theta,goal_ro);
            act_location = getActionLocation(this,Action);
            act_theta = act_location(2);
            act_ro = act_location(1);
            [act_x,act_y] = pol2cart(act_theta,act_ro);
            
            
            % Update system states
            this.State = {goal_location,act_location,Observation};
            
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
            
            i = this.counter;
            
            if i < this.index_amount
                goal_location = getGoalLocation(this,i);
                epoch = getEMG(this,i);
                this.counter = i + 1;
            end
            
            InitialObservation = epoch;
            act_location = this.State{2};
            this.State = {goal_location, act_location, InitialObservation};
            
            notifyEnvUpdated(this);

        end
    end
    %% Optional Methods (set methods' attributes accordingly)
   methods               
        %Helper methods to create the environment
        %Discrete force 1 or 2
        function action_location = getActionLocation(this,Action)
%             if ~ismember(Action,this.ActionInfo.Elements)
%                 error('Action is not valid');
%             end
            Action_theta = Action(2) * pi/180;
            Action_ro = Action(1) * 0.25;
            action_location = [Action_ro,Action_theta];           
        end
        
        function goal_location = getGoalLocation(this,i)
            data_location = load('rebeccaS1T1L.mat');
            location = data_location.location;
            goal_location_theta = location(i,2);
            goal_location_ro = location(i,1);
            goal_location = [goal_location_ro,goal_location_theta];
        end
           
        function index = getIndex(this,i)
            data_index = load('rebeccaS1T1I.mat');
            index = data_index.index;
            index = index(i);     
        end
        function epoch = getEMG(this,i)
            index = getIndex(this,i);
            data_whole_EMG = load('rebeccaS1T1d.mat');
            whole_EMG = data_whole_EMG.e;
            epoch = whole_EMG(index:index+1799,1:8);
        end 
         
        
        function plot(this)
            % Initiate the visualization
            this.Figure = figure('Visible','on','HandleVisibility','off');
            pax = polaraxes;
            pax.RLim = [0 1.25];
            pax = gca(this.Figure);
            hold(pax,'on');
            % Update the visualization
            envUpdatedCallback(this)
        end
% % %         
% 
    end
%     
    methods (Access = protected)
        % (optional) update visualization everytime the environment is updated 
        % (notifyEnvUpdated is called)
        function envUpdatedCallback(this)
            if ~isempty(this.Figure) && isvalid(this.Figure)
                % Set visualization figure as the current figure
                pax = gca(this.Figure);
                
                % draw the goal position area
                th_blue_marker = linspace(0,2*pi,30);
                [x_goal,y_goal] = pol2cart(th_blue_marker,this.blue_marker_radius);
                goal_center = this.state{1};
                theta_c = goal_center(2);
                ro_c = goal_center(1);
                [xc,yc] = pol2cart(theta_c,ro_c);
                [th_b,r_b] = cart2pol(x_goal + xc,y_goal + yc);
                polarplot(pax,th_b,r_b,'LineWidth',2);
                action_center = this.state{2};
                polarplot(pax, action_center(2),action_center(1),'.','MarkerSize',50,"color","r");
                
                % Refresh rendering in the figure window
                drawnow();
            end
        end
    end
end
