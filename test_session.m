%%initialisation
% polar axes


m1.startStreaming();

figure
pax = polaraxes;
pax.RLim = [0 1.25]
polarplot(0,0,'.','MarkerSize',50,'Color','r');
pause(3);

%random polar locations
rng(0,'twister');
%rand_theta = round((360-0).*rand(20,1));
% test for me rand_theta = round((12-0).*rand(20,1));
rand_theta = round((4-0).*rand(20,1));
%rand_ro = round((4-2).*rand(20,1)+2);
rand_ro = round((4-0).*rand(20,1)+4)
y = m1.isStreaming();
tic
m1.startStreaming();
e = m1.emg_log;
index = [1];
index2 = [1];
index_end = [1];
for k = 1:20
    e = m1.emg_log;
    index(length(index)+1) = length(e);
    %theta = pi/180 * rand_theta(k);
    %test for me theta = pi/60 * rand_theta(k);
    theta = pi/2;
    ro = 0.25 * rand_ro(k);
    ro_c = linspace(0,ro,20);
   
    for i = 1:20
        polarplot(theta,ro_c(20),'.','MarkerSize',50,'Color','r');
        hold on
        polarplot(theta,ro_c(i),'.','MarkerSize',50,'Color','r');
        pax.RLim = [0 1.25];
        drawnow
        pause(0.1);
        hold off
    end
    e = m1.emg_log;
    index2(length(index2)+1) = length(e);
    pause(3);
    e =m1.emg_log;
    index_end(length(index_end)+1) = length(e);
    for j = 1:20
        polarplot(theta,ro_c(21-j),'.','MarkerSize',50,'Color','r');
        pax.RLim = [0 1.25];
        drawnow
        pause(0.1);
    end
    pause(0.5);
end
m1.stopStreaming();
toc


