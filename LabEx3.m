%% BME Laboratory exercise 2 - Epoching and Averaging EEG data

clear;

%% Importing and loading data

scrz = get(groot,'ScreenSize')./2;
load('lab2_data_matlab.mat');
load('lab3_data_matlab.mat');

%% Calculating and Plotting Spectra
f = 150;
fs = 1000;
tmax = 2;
amp = 1;

tvec = GetTime(fs,tmax);

wav = amp*cos(2 * pi * f * tvec);
gaussnoise = normrnd(0,1,1,length(tvec));
noisy_wav = gaussnoise + wav;

dft = fft(noisy_wav);
P2 = abs(dft/length(noisy_wav));

fvec = fs*(0:length(noisy_wav)-1)/length(noisy_wav);

figure('Color',[1 1 1],'NumberTitle','off','Name','150Hz Cosine With Gaussian Noise','Position',scrz);
subplot(2,1,1)
plot(tvec,noisy_wav)
ylabel('AU'); xlabel('Time (s)');
title('150Hz Cosine wave with Guassian Noise');

subplot(2,1,2);
plot(fvec,P2);
title('Discrete Fourier Transform');


%% Numerical precision of the FFT

%generate a vector of random vlues
x = rand(500,1);

x(1:10)

x_dft = fft(x);

x_idft = ifft(x_dft);

x_idft(1:10)

length(find(x == x_idft))

%%


