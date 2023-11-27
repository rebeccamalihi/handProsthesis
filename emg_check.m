function emg_check(name)

folderName = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name);
fds = fileDatastore(folderName, 'FileExtensions', '.mat','ReadFcn', @importdata );
data = read(fds);


end
