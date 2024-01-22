%function dataConvertor(name,session)
%%this function is created to convert the raw signals to images with size of 40*40
session = 1; 
name = "Reb";
folderName = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name);
fds = fileDatastore(folderName, 'FileExtensions', '.mat','ReadFcn', @importdata );
%data = read(fds);
list = readall(fds);
data = list{session};
% for i = 1:length(list)
%     for j =1:12
%         data_a = list{i};
%         a = data_a.data;
%         data{12*(i - 1)+ j} = a{j};
%     end
% end
for i =1:4
    subFolderName = int2str(i * 90);
    subFolderAddress = fullfile(name + '\' + subFolderName);
    mkdir(subFolderAddress);
end
% mkdir Reb\ 90
% mkdir Reb\ 180
% mkdir Reb\ 270
% mkdir Reb\ 360
for i = 1:length(data)
    sample = data{i};
    for j = 1:15
        imageName = sprintf('Sample%dS%dT%d.jpeg', j, session, i);
        fileName = fullfile(folderName + '\' + sample.label + '\' + imageName);
        index_s = (j-1)*40 + 1;
        index_e = index_s + 39;
        img_matrix = sample.signal(index_s:index_e,:);
        img_resize = repelem(img_matrix,1,5);
        imwrite(img_resize,fileName);
    end
end


%end