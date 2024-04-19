%%This program is to display online monitoring of the myoband 8 channels in
%%form of signals and imgs display time domaine is 1sec and frequensy is
%%200Hz
% mm = MyoMex;
% m1 = mm.myoData;
function out = emg_display(data)
e = [];
for i= 1:length(data)
    sig = data{i};
    signal = sig.signal;
    e = [e;signal];
end

%%
    e1 = e(:,1);
    e2 = e(:,2);
    e3 = e(:,3);
    e4 = e(:,4);
    e5 = e(:,5);
    e6 = e(:,6);
    e7 = e(:,7);
    e8 = e(:,8);
    figure(2);subplot(8,1,1);plot(e1);ylim([-1, 1]);
    figure(2);subplot(8,1,2);plot(e2);ylim([-1, 1]);
    figure(2);subplot(8,1,3);plot(e3);ylim([-1, 1]); 
    figure(2);subplot(8,1,4);plot(e4);ylim([-1, 1]); 
    figure(2);subplot(8,1,5);plot(e5);ylim([-1, 1]); 
    figure(2);subplot(8,1,6);plot(e6);ylim([-1, 1]); 
    figure(2);subplot(8,1,7);plot(e7);ylim([-1, 1]); 
    figure(2);subplot(8,1,8);plot(e8);ylim([-1, 1]); 
    % emg_matrix = abs(e(end-49:end,:));
    % imwrite(emg_matrix,'emgpic.jpeg');
    % emg_img =imread('emgpic.jpeg');
    % emg_squared = imresize(emg_img,[200 200]);

%%
% [b,a] = butter(2,10/(200/2),"high");
% d = filtfilt(b,a,e);
% %%
% e = d;
%     e1 = e(:,1);
%     e2 = e(:,2);
%     e3 = e(:,3);
%     e4 = e(:,4);
%     e5 = e(:,5);
%     e6 = e(:,6);
%     e7 = e(:,7);
%     e8 = e(:,8);
%     figure(3);subplot(8,1,1);plot(e1);ylim([-1, 1]);
%     figure(3);subplot(8,1,2);plot(e2);ylim([-1, 1]);
%     figure(3);subplot(8,1,3);plot(e3);ylim([-1, 1]); 
%     figure(3);subplot(8,1,4);plot(e4);ylim([-1, 1]); 
%     figure(3);subplot(8,1,5);plot(e5);ylim([-1, 1]); 
%     figure(3);subplot(8,1,6);plot(e6);ylim([-1, 1]); 
%     figure(3);subplot(8,1,7);plot(e7);ylim([-1, 1]); 
%     figure(3);subplot(8,1,8);plot(e8);ylim([-1, 1]); 
out = e;
end
