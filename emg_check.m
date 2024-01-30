% function data = emg_check(name)
name= 'Reb';
folderName = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name);
fds = fileDatastore(folderName, 'FileExtensions', '.mat','ReadFcn', @importdata);
data = read(fds);

