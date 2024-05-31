prompt = "Enter the file name:";
file = input(prompt,"s");
file_name = sprintf('stats%s.mat', file);
%myAgent = agent_Trained;

%% online check of the performance of the cnn
data_log = {};
time_log = {};
results = {};

Figure = figure('Visible','on','HandleVisibility','off');
p = gca(Figure);
target_list = [0,3*pi/4,3*pi/2,pi/4,pi,7*pi/4,pi/2,5*pi/4];
e = m1.emg_log;

for k = 1:6
    remainder = rem(k,2);
    switch remainder
        case 1
            ro = 1;
        case 0
            ro =0.5;
    end
        
    for j = 1:length(target_list)
        reset(p)
        th = 0 : pi/50:2*pi;
        xunit = 1 * cos(th) + 0;
        yunit = 1 * sin(th) + 0;
        plot(p,xunit,yunit);
        hold(p,"on");
        xline(p,0);
        yline(p,0);
        th_blue_marker = linspace(0,2*pi,30);
        [x_blue,y_blue] = pol2cart(th_blue_marker,0.1);
        goal_center = target_list(j);
        [xc_goal,yc_goal] = pol2cart(goal_center,ro);
        x_goal = x_blue + xc_goal;
        y_goal = y_blue + yc_goal;
        goalArea = plot(p,x_goal,y_goal,"Color",'b'); drawnow;
        scatter(p,0,0,"green"); drawnow;
        x = 0;
        y = 0;
        data = [];
        time = 0;
        timer = 0;
        prompt = "Are you Ready? [y/n]";
        txt = input(prompt,"s");
        if isempty(txt)
            txt = 'y';
        end
        in = false;
        if txt == 'y'
            result = 'fail';
            while timer < 5
                tic
                e = m1.emg_log;
                %                 figure(2);plot(e(end-39:end,1));
                img_matrix = abs(e(end-55:end,:));
                [img_envelope,~] = envelope(img_matrix,5);
                img_resize(:,:,1) = repelem(img_envelope,1,7);
                file = "EMGsample.jpeg";
                imwrite(img_resize,file,"jpeg");
                ss = imread("EMGsample.jpeg");

                Observation =  im2double(ss);
              
                pred = predict(net,Observation);
                x = pred(1);
                y = pred(2);
                current_data = [x,y];
                scatter(p,x,y,"green");
                drawnow
                time =[time;toc];
                timer = timer+toc;
%                 dist = 5;
                dist = sqrt((x-xc_goal)^2 + (y-yc_goal)^2)
                if dist <= 0.1
                    in = in + toc
                    if in > 1
                        result = 'success';
                        timer = 10;
                    end
                else
                    in= 0;
                end
                disp(result)
                time =[time;toc];
                data = [data;current_data];
            end

        end
        data_log{k,j} = data;
        time_log{k,j} = time;
        results{k,j} = result;

    end
end
save(file_name,"results","time_log","data_log")
