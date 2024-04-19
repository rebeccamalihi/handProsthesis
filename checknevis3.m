diferense = abs(ypred(:,1)-YTest(:,1));
x = find(diferense>0.1);
figure(5);scatter(ypred(:,1),ypred(:,2)); hold on;
scatter(ypred(x(:),1),ypred(x(:),2));

