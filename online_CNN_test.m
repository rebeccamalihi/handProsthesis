%% online check of the performance of the cnn
i = 0;
for i = 1:1000000
    circle(0,0,1)
    e = m1.emg_log;
    mat = abs(e(end-39:end,:));
    img_resize(:,:,1) = repelem(mat,1,5);
    imwrite(img_resize,"sample.jpeg");
    emg_img =imread('sample.jpeg');
    YPred = predict(net,emg_img);
    scatter(YPred(1),YPred(2));drawnow
    emg_squared = imresize(emg_img,[400 400]);
    figure(2);
    imshow(emg_squared);
    pause(3);

end

function h = circle(x,y,r)
hold on
th = 0 : pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h = plot(xunit,yunit);
end


