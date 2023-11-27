%% This program is to display the ras signals of 8 channels
mm = MyoMex;
m1 = mm.myoData;
e = m1.emg_log;
e1 = abs(e(:,1));
e2 = abs(e(:,2));
e3 = abs(e(:,3));
e4 = abs(e(:,4));
e5 = abs(e(:,5));
e6 = abs(e(:,6));
e7 = abs(e(:,7));
e8 = abs(e(:,8));
figure(1); subplot(4,1,1); plot(e1); ylim([-1,1]);
figure(1); subplot(4,1,2); plot(e2); ylim([-1,1]);
figure(1); subplot(4,1,3); plot(e3); ylim([-1,1]);
figure(1); subplot(4,1,4); plot(e4); ylim([-1,1]);
figure(2); subplot(4,1,1); plot(e5); ylim([-1,1]);
figure(2); subplot(4,1,2); plot(e6); ylim([-1,1]);
figure(2); subplot(4,1,3); plot(e7); ylim([-1,1]);
figure(2); subplot(4,1,4); plot(e8); ylim([-1,1]);
