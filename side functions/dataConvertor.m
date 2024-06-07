%function dataConvertor(name,session)
%%this function is created to convert the raw signals to images with size of 40*40
%session = 1; 
name = "Rebecka";
folderName = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name);
fds = fileDatastore(folderName, 'FileExtensions', '.mat','ReadFcn', @importdata );
%data = read(fds);
list = readall(fds);
numberOfSessions = length(fds.Files);
for i = 1:length(list)
    data = list{i};%ino dorost kon
end
trialPerSession = length(data);
fs = 200;%Hz
emgMatPerTrial = length(data{1}.signal)*5/fs;
%% 
for i =1:4
    subFolderName = int2str(i * 90);
    subFolderAddress = fullfile(name + '\' + subFolderName);
    mkdir(subFolderAddress);
end
%% 
for j = 1:numberOfSessions
    data = list{j};
    for k = 1:trialPerSession
        sample = data{k};
        for z = 1:emgMatPerTrial
            imageName = sprintf('Sample%dS%dT%d.jpeg', z, j, k);
            fileName = fullfile(folderName + '\' + sample.label + '\' + imageName);
            index_s = (j-1)*40 + 1;
            index_e = index_s + 39;
            img_matrix = abs(sample.signal(index_s:index_e,:));
            img_resize = repelem(img_matrix,1,5);
            imwrite(img_resize,fileName);
        end
    end
end
%end
