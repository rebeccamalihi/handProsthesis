%my checknevis
% alan daram kar mikonam ru inke chejuri mishe esme signalaro dorost kard
name = "Rebecka";
folderName = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name);
fds = fileDatastore(folderName, "ReadFcn", @load, 'FileExtensions', '.mat');
list = readall(fds);
data = {};
for i = 1:length(list)
    for j =1:12
        data_a = list{i};
        a = data_a.data;
        data{12*(i - 1)+ j} = a{j};
    end
end