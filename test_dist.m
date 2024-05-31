% distance
load centers.mat
dist = {};
dist_mean = 0;
mean_of_each = [];
for i = 1:6
    for j = 1:8
        v1 = [0,0];
        v2 = centers{i,j};
        pt = data_log{i,j};
        dist{i,j} = point_to_line_distance(pt,v1,v2);
        dist_mean(i,j) = mean(dist{i,j});
    end
end

for i = 1:8
    r_mean = mean(dist_mean(:,i));
    mean_of_each =[mean_of_each,r_mean];
end
mean_of_all = mean(mean_of_each);
