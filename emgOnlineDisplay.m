%% emg display
e = 0;
for i = 1:1000000
    e = m1.emg_log;
    e1 = e(end-999:end,1);
    e2 = e(end-999:end,2);
    e3 = e(end-999:end,3);
    e4 = e(end-999:end,4);
    e5 = e(end-999:end,5);
    e6 = e(end-999:end,6);
    e7 = e(end-999:end,7);
    e8 = e(end-999:end,8);
    figure(1);subplot(8,1,1);plot(e1);ylim([-1, 1]); drawnow;
    figure(1);subplot(8,1,2);plot(e2);ylim([-1, 1]); drawnow;
    figure(1);subplot(8,1,3);plot(e3);ylim([-1, 1]); drawnow;
    figure(1);subplot(8,1,4);plot(e4);ylim([-1, 1]); drawnow;
    figure(1);subplot(8,1,5);plot(e5);ylim([-1, 1]); drawnow;
    figure(1);subplot(8,1,6);plot(e6);ylim([-1, 1]); drawnow;
    figure(1);subplot(8,1,7);plot(e7);ylim([-1, 1]); drawnow;
    figure(1);subplot(8,1,8);plot(e8);ylim([-1, 1]); drawnow;
    pause(0.1);
end

