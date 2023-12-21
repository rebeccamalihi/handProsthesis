%% online check of the performance of the cnn
i = 0;
for i = 1:1000000
    th = 0 : pi/50:2*pi;
    xunit = 1 * cos(th) + 0;
    yunit = 1 * sin(th) + 0;
    figure(1);
    hold on
    plot(xunit,yunit);
    e = m1.emg_log;
    mat = abs(e(end-39:end,:));
    img_resize(:,:,1) = repelem(mat,1,5);
    imwrite(img_resize,"sample.jpeg");
    emg_img =imread('sample.jpeg');
    YPred = predict(net,emg_img);
    figure(1);scatter(YPred(1),YPred(2));
    hold off
    emg_squared = imresize(emg_img,[400 400]);
    figure(2);
    imshow(emg_squared);
    pause(0.5);

end




