%load marker_values.mat
figure

pax = polaraxes;
pax.RLim = [0 1.1]
th_blue_marker = linspace(0,2*pi,30);
xc = linspace(0,1,20);
r = 0.08;
[x,y] = pol2cart(th_blue_marker,r);

for k = 1:3
    yc = 0;
    xc = linspace(0,1,20);
    %blue circle around the center 
    [th1,r1] = cart2pol(x + xc(1),y + yc);
    polarplot(th1,r1,'LineWidth',2);
    pax.RLim = [0 1.1];
    drawnow


    hold on
    for j = 1:30
        [th2,r2] = cart2pol(x + xc(1),y + yc);
        polarplot(th2(j),r2,'.','MarkerSize',10,"color","r");
        pax.RLim = [0 1.1];
        drawnow
        %pause(0.01);

    end
    hold off

    for i = 1:20
        [th1, r1] = cart2pol( x+xc(i), y + yc );
        polarplot(th1, r1,'LineWidth',2); 
        pax.RLim = [0 1.1];
        drawnow
        pause(0.1);


    end
    hold on
    for j = 1:30
        [th0,r0] = cart2pol(x(j) + xc(end),y + yc);
        polarplot(th0(j),r0,'.','MarkerSize',10,"color","r");
        pax.RLim = [0 1.1];
        drawnow
        %pause(0.01);

    end
    hold off

    for i = 1:20
        xc(1,i);
        [th1, r1] = cart2pol( x-xc(i)+1, y+yc );
        polarplot(th1, r1,'LineWidth',2);
        pax.RLim = ([0 1.1]);
        drawnow
        pause(0.1);
    end

    hold on
    for j = 1:30
        [th2,r2] = cart2pol(x + xc(1),y + yc);
        polarplot(th2(j),r2,'.','MarkerSize',10,"color","r");
        pax.RLim = [0 1.1];
        drawnow
        %pause(0.01);

    end
    hold off

    for i = 1:20
        xc(1,i);
        [th1, r1] = cart2pol( x-xc(i), y+yc );
        polarplot(th1, r1,'LineWidth',2);
        pax.RLim = ([0 1.1]);
        drawnow
        pause(0.1);
    end

    hold on
    for j = 1:30
        [th180,r180] = cart2pol(x(j) - xc(end),y + yc);
        polarplot(th180(j),r180,'.','MarkerSize',10,"color","r");
        pax.RLim = [0 1.1];
        drawnow
        %pause(0.01);

    end
    hold off

    for i = 1:20
        xc(1,i);
        [th1, r1] = cart2pol( x + xc(i) - 1, y + yc );
        polarplot(th1, r1,'LineWidth',2);
        pax.RLim = ([0 1.1]);
        drawnow
        pause(0.1);
    end
    hold on
    for j = 1:30
        [th2,r2] = cart2pol(x + xc(1),y + yc);
        polarplot(th2(j),r2,'.','MarkerSize',10,"color","r");
        pax.RLim = [0 1.1];
        drawnow
        %pause(0.01);

    end
    hold off
    xc = 0;
    yc = linspace(0,1,20);
    for i = 1:20
        [th1, r1] = cart2pol(x + xc, y + yc(i));
        polarplot(th1, r1,'LineWidth',2); 
        pax.RLim = [0 1.1];
        drawnow
        pause(0.1);


    end
    hold on
    for j = 1:30
        [th180,r180] = cart2pol(x + xc,y(j) + yc(end));
        polarplot(th180(j),r180,'.','MarkerSize',10,"color","r");
        pax.RLim = [0 1.1];
        drawnow
        %pause(0.01);

    end
    hold off


    for i = 1:20
        [th1, r1] = cart2pol(x + xc, y - yc(i)+1 );
        polarplot(th1, r1,'LineWidth',2); 
        pax.RLim = [0 1.1];
        drawnow
        pause(0.1);


    end
    hold on
    for j = 1:30
        [th2,r2] = cart2pol(x + xc,y + yc(1));
        polarplot(th2(j),r2,'.','MarkerSize',10,"color","r");
        pax.RLim = [0 1.1];
        drawnow
        %pause(0.01);

    end
    hold off

    for i = 1:20
        [th1, r1] = cart2pol(x + xc, -y - yc(i));
        polarplot(th1, r1,'LineWidth',2); 
        pax.RLim = [0 1.1];
        drawnow
        pause(0.1);


    end

    hold on
    for j = 1:30
        [th180,r180] = cart2pol(x + xc,y(j) - yc(end));
        polarplot(th180(j),r180,'.','MarkerSize',10,"color","r");
        pax.RLim = [0 1.1];
        drawnow
        %pause(0.01);

    end
    hold off

    for i = 1:20
        [th1, r1] = cart2pol(x + xc, y + yc(i)-1);
        polarplot(th1, r1,'LineWidth',2); 
        pax.RLim = [0 1.1];
        drawnow
        pause(0.1);


    end
end