figure
pax = polaraxes;
th_blue_marker = linspace(0,2*pi,30);
xc = linspace(0,1,20);
r = 0.08;
[x,y] = pol2cart(th_blue_marker,r);
pax.RLim = [0 1.1]
yc = 0;
hold on


% %blue circle around the center 
% [th1,r1] = cart2pol(x + xc(1),y + yc);
% %polarplot(th1,r1,'LineWidth',2);
% %pax.RLim = [0 1.1];
% %drawnow

% red circle around the center 
for j = 1:30
    [thc,rc] = cart2pol(x + xc(1),y + yc);
    polarplot(thc(j),rc,'.','MarkerSize',20,"color","r");
    pax.RLim = [0 1.1];
    drawnow;
    pause(0.01);   
end

%red circle around 0 
for j = 1:30
    [th0,r0] = cart2pol(x(j) + xc(end),y + yc);
    polarplot(th0(j),r0,'.','MarkerSize',20,"color","r");
    pax.RLim = [0 1.1];
    drawnow;
    pause(0.01);   
end


%red circle around 180

for j = 1:30
    [th180,r180] = cart2pol(-x(j) - xc(end),y + yc);
    polarplot(th180(j),r180,'.','MarkerSize',20,"color","r");
    pax.RLim = [0 1.1];
    
end

%red circle around 90
xc = 0;
yc = linspace(0,1,20);
for j = 1:30
    [th90,r90] = cart2pol(x + xc,y(j) + yc(end));
    polarplot(th90(j),r90,'.','MarkerSize',20,"color","r");
    pax.RLim = [0 1.1];
    
end

%red circle around 270
for j = 1:30
    [th270,r270] = cart2pol(x + xc,-y(j) - yc(end));
    polarplot(th270(j),r270,'.','MarkerSize',20,"color","r");
    pax.RLim = [0 1.1];
    
end

hold off
file_name = 'marker_values.mat';
save(file_name)
