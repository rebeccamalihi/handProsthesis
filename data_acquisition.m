
function data = data_acquisition(name,session,m1)
%this function is desinged for only 4 maximum position sample aquisition.it
%includes three trials per position and each trial lasts for 3sec. 'name'
%of the subject, number of the current 'session' and the m1 object must be
%given as arguments

%% variables

data = {};
gestureNum = 5; %number of time for each guster to be performed
pTime = 5; %seconds for each gesture
% EmgDisplay = uifigure('Visible','on','HandleVisibility','off');
% emgCg = uigauge(EmgDisplay,"Position",[100 60 350 350]);
figure
pax = polaraxes;
pax.RLim = [0 1.25];
polarplot(0,0,'.','MarkerSize',50,'Color','r');
pause(3); %gives time to the subject to be prepared
y = m1.isStreaming();
tic
m1.startStreaming();
e = m1.emg_log;
index = [1];
index2 = [1];
index_end = [1];
folder_name = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name);

%% %prepare directory to save the images
if ~exist(folder_name,'dir')
    mkdir(folder_name);
end
%%

for k = 1:4 %each quadrant from pi/2 to 2pi is in the que
    theta = k * pi/2;
    sample.label = string(rad2deg(theta)); %make the label for each signal junk
    % subFolderAddress = fullfile(name + '\' + sample.label);
    % if ~exist(subFolderAddress,'dir')
    %     mkdir(subFolderAddress);
    % end
    ro = 1;
    ro_c = linspace(0,ro,20); %ro of centre
    for f = 1:gestureNum % times each gesture is performed
        trial_number = f; %number of trials in each session
        for i = 1:20
            polarplot(theta,ro_c(20),'.','MarkerSize',50,'Color','r');
            hold on
            polarplot(theta,ro_c(i),'.','MarkerSize',50,'Color','r');
            pax.RLim = [0 1.25];
            drawnow
            pause(0.1);
            hold off
        end
        %e = m1.emg_log;
        %index2(length(index2)+1) = length(e);%start the recording

        pause(pTime);
        e =m1.emg_log;
        sample.signal = e(end-(200*pTime-1):end,:);
        data{end+1} = sample;% stores the pTime second long signal with labels

        %index_end(length(index_end)+1) = length(e);%end of recording
        for j = 1:20
            polarplot(theta,ro_c(21-j),'.','MarkerSize',50,'Color','r');
            pax.RLim = [0 1.25];
            drawnow
            pause(0.1);
        end
        pause(0.5);
        %fileName = fullfile(folder_name + '\' + name + sample.label +'S' + session + 'T' + trial_number);
        fileName = fullfile(folder_name + '\' + 'rawData' + 'S' + session);

    end
end
m1.stopStreaming();
toc
save(fileName,"data");
end


