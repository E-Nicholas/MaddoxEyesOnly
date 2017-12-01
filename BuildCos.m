function [tvec, wav] = BuildCos(f,fs,timelength,amp)
% BuildSin will build a sin wave with the specified input parameters
% and return a time vector (tvec) and signal (wav)
%
% Units for input parameters are seconds
%
% f = frequeny of desired sin wave
% fs = sampling rate
% timelength = length of desired signal
% amp = peak amplitude of desired signal
%
% example: [x,y] = BuildSin(10,1000,1,0.5)
% will return 1 second of a 10Hz sin wave at 1kH sampling rate
% with x being the time vector with units of seconds
% and y carrying the desired signal
% Eric Nicholas 2017
dt = 1/fs;

tvec = dt:dt:timelength;
wav = amp*cos(2 * pi * f/fs * tvec * fs);

end