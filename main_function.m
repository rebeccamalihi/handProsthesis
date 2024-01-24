%%this program has been prepared for data aquisition and validation and
%%converting the signal samples to image samples. outputs are resized images
%%of the recoreded signals from 8 channles of myoband with duration of 200
%%msec. myo band has the frequency of 200Hz therefor, initial imgsize is
%%40*8 and finale imgsize is 40*40. images are saved in .jpeg format and
%%stored in folders with lables under the name of test subjects.

%% Variable Initialisation
prompt = "Please the name of participant: ";
name = input(prompt,'s');
prompt = "Session number: ";
session = input(prompt,'s');
if isempty(name)
    name = "Rebecca";
end
mm = MyoMex();
m1 = mm.myoData;

%% main program
data = data_acquisition(name, session,m1);
emg_display(data);
prompt = "should we proceed?[y/n]";
reply = input(prompt,'s');
emg_check(name)
if reply == 'y'
    dataConvertor(name);
    disp("Thank you for your time.")
else
    disp("Sorry your samples are not valid,please try again.")
end
