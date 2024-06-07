%checknevis2
%goal_location = getGoalLocation(this)
i = 0;
rand_goal_location = 1.1;
while rand_goal_location > 1
    rand_goal = -1 + 2 * rand(1,2);
    rand_goal_location = sqrt(rand_goal(1)^2+rand_goal(2)^2);
    i = i + 1;
end
disp(i);


