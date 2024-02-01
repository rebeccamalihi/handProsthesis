            mm = MyoMex();
            m1 = mm.myoData();
            Fs = 200;
            pause(1);
            e = m1.emg_log;
            time0 = length(e)/Fs;
            timespace = 0;
            figure(1)
            meanMVC = 0;
            hold on
            % for i =1:10 % ~app.StopButton.Value
            for i = 1:20
                e = m1.emg_log;
                timeSample = length(e)/Fs-time0;
                timespace = [timespace,timeSample];
                sig = abs(e(end-99:end,:)); %200 ms time window just like the whole system
                meanF = signalTimeFeatureExtractor("Mean", true, 'SampleRate', Fs);
                meanFDS = arrayDatastore(sig,"IterationDimension",2);
                meanFDS = transform(meanFDS,@(x)meanF.extract(x{:}));
                meanFeatures = readall(meanFDS,"UseParallel",true);
                meanMVC = [meanMVC,mean(meanFeatures)];
                figure(1);plot(timespace',meanMVC','b--o',MarkerFaceColor='cyan',LineWidth=2,Color='blue');drawnow
                pause(0.5);
            end
            mm.delete;
            clear('mm');
