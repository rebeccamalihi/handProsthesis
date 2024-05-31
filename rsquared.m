%calcute rsquared
rx = 0;
ry = 0;
% centers = {};
% target_list = [0,3*pi/4,3*pi/2,pi/4,pi,7*pi/4,pi/2,5*pi/4];
% ro_list = [1,0.5,1,0.5,1,0.5];
% for j = 1:6
%     for i=1:length(target_list)
%         angle = target_list(i);
%         ro = ro_list(j);
%         center = [angle,ro];
%         [x,y] =  pol2cart(angle,ro);
%         centers{j,i} = [x,y];
%     end
% end
for i = 1:6
    for j = 1:8
        target_point = centers{i,j};
        predicted_data = data_log{i,j};
        target_line_x = linspace(0,target_point(1),length(predicted_data));
        target_line_y = linspace(0,target_point(2),length(predicted_data));
        eror_x = (target_line_x' - predicted_data(:,1)).^2;
        sum_eror_x = sum(eror_x);
        eror_y = (target_line_y' - predicted_data(:,2)).^2;
        sum_eror_y = sum(eror_y);
        mean_x = mean(target_line_x);
        vec_meanx = zeros(length(target_line_x),1) + mean_x;
        mean_y = mean(target_line_x);
        vec_meany = zeros(length(target_line_y),1) + mean_y;
        x_xbar = (target_line_x' - vec_meanx).^2;
        sum_xbar = sum(x_xbar);
        y_ybar = (target_line_y' - vec_meany).^2;
        sum_ybar = sum(y_ybar);
        rsquar_x = 1-((sum_eror_x)/sum_xbar);
        rsquar_y = 1-((sum_eror_y)/sum_ybar);
        rx(i,j) = rsquar_x;
        ry(i,j) = rsquar_y;
    end
end