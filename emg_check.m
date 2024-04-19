% % function data = emg_check(name)
% name= 'Rebexis';
% lbl = '270';
% folderName = fullfile("\Users\lab-admin\Desktop\Rebecca\" + name + '\' + lbl);
% fds = fileDatastore(folderName, 'FileExtensions', '.mat','ReadFcn', @importdata);
% data = readall(fds);
% sig = data{1};
% mvc = 33.2715;
% NumOfWindows = round(length(sig)/40);
% Fs = 200;
% y = [];
% for i= 1:8
%     y(:,i,:) = buffer(sig(:,i),40);
% end
% intention = [];
% for j = 1:length(y)
%     window = abs(y(:,:,j));
%     meanF = signalTimeFeatureExtractor("Mean", true, 'SampleRate', Fs);
%     meanFDS = arrayDatastore(window,"IterationDimension",2);
%     meanFDS = transform(meanFDS,@(x)meanF.extract(x{:}));
%     meanFeatures = readall(meanFDS,"UseParallel",true);
%     meanMVC = mean(meanFeatures);
%     intention = [intention; meanMVC*100/mvc];
% end
% 
% gestures = find(intention > 0.6);
% figure(1)
% hold on
% plot(sig(:,1));
% xline((gestures-1)*40,'--r');
% hold off




