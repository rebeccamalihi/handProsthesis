% function data = emg_check(name)
name= 'Rebexis';
folderName = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name + '270');
fds = fileDatastore(folderName, 'FileExtensions', '.mat','ReadFcn', @importdata);
data = readall(fds);

