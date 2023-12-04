%regression test
% 
% function pureRegressionTest

imgSamples = {};
for k =1:124
    filename = imdsTrain.Files{k};
    img = imread(filename);
    imgSamples{k} = img;

   
end
response = imdsTrain.Labels;
x = [];
y = [];
for i = 1:length(response)
    [xTemp,yTemp] = pol2cart(response(i),1);
    x = [x;xTemp];
    y = [y;yTemp];
end
regTable = table(x,y);


% end

%[trainedModel, validationRMSE] = trainRegressionModel()