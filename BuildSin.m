function [tvec, wav] = BuildSin(f,fs,timelength,amp)
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
% with x being the time vector and y carrying the desired signal

dt = 1000/fs;

tvec = dt:dt:timelength*1000;
wav = amp*sin(2 * pi * f/fs * tvec);

end