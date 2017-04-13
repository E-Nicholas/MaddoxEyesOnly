%% BME Laboratory exercise 2 - Epoching and Averaging EEG data

clear;

%% Importing and loading data

scrz = get(groot,'ScreenSize')./2;
load('lab2_data_matlab.mat');
load('lab3_data_matlab.mat');

tvec = GetTime(1000,2);

