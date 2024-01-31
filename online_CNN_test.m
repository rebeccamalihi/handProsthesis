%% online check of the performance of the cnn
i = 0;
Figure = figure('Visible','on','HandleVisibility','off');
p = gca(Figure);
for i = 1:1000000
    th = 0 : pi/50:2*pi;
    xunit = 1 * cos(th) + 0;
    yunit = 1 * sin(th) + 0;
    e = m1.emg_log;
    mat = abs(e(end-39:end,:));
    img_resize(:,:,1) = repelem(mat,1,5);
    imwrite(img_resize,"sample.jpeg");
    emg_img =imread('sample.jpeg');
    plot(p,xunit,yunit);
    hold(p,"on");
    YPred = predict(net,emg_img);
    scatter(p,YPred(1),YPred(2));
    hold(p,"off");
    pause(1);
end




