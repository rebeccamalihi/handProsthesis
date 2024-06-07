%% here i make intermidiate small functions,just to try some code, then we
fs = 200; %Hz
sig90 = [];
sig180 = [];
sig270 = [];
sig360 = [];

for i = 1:5
    filename = fullfile ("C:\Users\lab-admin\Desktop\Rebecca\Rebecka\rawDataS" + i + ".mat" );
    load(filename, "data")
    for j = 1: length(data)
        label = data{j}.label;
        signal = data{j}.signal;
        switch label
            case '90'
                sig90 = [sig90;signal];
            case '180'
                sig180 = [sig180;signal];
            case '270'
                sig270 = [sig270;signal];
            case '360'
                sig360 = [sig360;signal];
        end

    end
end
sig90 = abs(sig90);

meanF = signalTimeFeatureExtractor("Mean", true, 'SampleRate', fs);
timeF = signalTimeFeatureExtractor("ClearanceFactor",true,...
    "RMS",true,...
    "ShapeFactor",true,...
    "CrestFactor",true,...
    "PeakValue",true,...
    "ImpulseFactor",true,...
    "SampleRate", fs);
freqF = signalFrequencyFeatureExtractor("PeakAmplitude",true,...
    "PeakLocation",true,...
    "MeanFrequency",true,...
    "BandPower",true,...
    "PowerBandwidth", true, ...
    "SampleRate",fs);
features = [];
windowSize = fs/5;
windowNum = length(sig90)/windowSize;
for k = 1:windowNum
    sigTemp = sig90((k-1)*windowSize+1:k*windowSize-1,:);
    meanFDS = arrayDatastore(sigTemp,"IterationDimension",2);
    meanFDS = transform(meanFDS,@(x)meanF.extract(x{:}));
    meanFeatures = readall(meanFDS,"UseParallel",true);
    features = [features, meanFeatures];
end
figure(1);subplot(4,1,1);plot(features(1,:)); ylim([0,1]);
figure(1);subplot(4,1,2);plot(features(2,:)); ylim([0,1]);
figure(1);subplot(4,1,3);plot(features(3,:)); ylim([0,1]);
figure(1);subplot(4,1,4);plot(features(4,:)); ylim([0,1]);
figure(2);subplot(4,1,1);plot(features(5,:)); ylim([0,1]);
figure(2);subplot(4,1,2);plot(features(6,:)); ylim([0,1]);
figure(2);subplot(4,1,3);plot(features(7,:)); ylim([0,1]);
figure(2);subplot(4,1,4);plot(features(8,:)); ylim([0,1]);

