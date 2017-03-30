%BME 425 Laboratory exercise 1 - Eric Nicholas

%reminder: quickly evaluate the selected cell with ctrl-Enter
clearvars

%% Cell 1 - Generating signals - 15Hz...
l = 0.2;   %Time vector from 0-200ms
amp = 0.1; %Amplitude = 0.1
fs = 1000; %Sampling rate, dt = 1ms
f = 15;    %Desired frequency

[tvec, wav] = BuildSin(f,fs,l,amp); %type 'help BuildSin' for more info

figure('Color',[1 1 1],'NumberTitle','off'); %gotta love (read: sarcasm) plotting in MatLab
plot(tvec,wav,'LineWidth',2);
title('15Hz sine wave with peak amplitude = 0.1, fs = 1000;');
xlabel('Time (ms)'); ylabel('AU');

%% Cell 2 - Resampling and Decimation Exercise - Starting with 1 second of 25Hz at
% 600Hz fs
scrz = get(groot,'ScreenSize')./2;
fs = 600; %600Hz sample rate
f = 25;   %25 Hz signal
l = 1;    %1 second of signal
amp = 1;  %peak amplitude = 1

[tvec, wav] = BuildSin(f,fs,l,amp); %ah yis

fsdown = [100 50 30 25 20]; %desired sampling rates for decimted and resampled signals
takeevery = fs./fsdown;         %points to take in decimated signals

[wavs_ds{1}, wavs_fds{1}, wavs_dc{1}] = deal(wav); %Set the first element in cell arrays
tvecs_dc{1,:} = tvec;
for i = 1:length(fsdown)                            % Resample and decimate (using two methods for resample)
    wavs_ds{i+1,:} = resample(wav,fsdown(i),fs);      %'resample' uses a polyphase FIR method
    wavs_fds{i+1,:} = interpft(wav,fsdown(i));      %'interpft' uses fourier interpolation method
    wavs_dc{i+1,:} = wav(1:takeevery(i):length(wav)); %decimation method
    tvecs_dc{i+1,:} = tvec(1:takeevery(i):length(tvec)); %decimating time vector
end

for i = 1:length(wavs_ds)
    ds_RMS(i) = RootMS(wavs_ds{i},1);
    fds_RMS(i) = RootMS(wavs_fds{i},1);
    dc_RMS(i) = RootMS(wavs_dc{i},1);
end

figure('Color',[1 1 1],'NumberTitle','off','Name','Resampled and Decimated signals','Position',scrz); %plotting resampled and decimated signals
for i = 1:length(fsdown)+1         %!in a loooop!
    lp(i) = subplot(6,2,i+(i-1));  %left column plots
    plot(tvecs_dc{i},wavs_fds{i}); %plot 'em!
    set(gca,'xlim',[0 tvecs_dc{i}(end)]);
    axpos = get(lp(i),'Position');
    txtpos = [axpos(1)+axpos(3)*1.01 axpos(2)+axpos(4)/2 0.05 0.05];
    tboxl = uicontrol('style','text','BackgroundColor',[1 1 1],'string',{'RMS = '; num2str(fds_RMS(i))},'Units','Normal','Position',txtpos);
    if i == length(fsdown)+1       %Put an x-label on the last left plot
        xlabel('Time (ms)');
    end
    ylabel('AU');
    rp(i) = subplot(6,2,i+(i-1)+1);%right column plots
    plot(tvecs_dc{i},wavs_dc{i});  %plot 'em!
    set(gca,'xlim',[0 tvecs_dc{i}(end)]);
    axpos = get(rp(i),'Position');
    txtpos = [axpos(1)+axpos(3)*1.01 axpos(2)+axpos(4)/2 0.05 0.05];
    tbox2 = uicontrol('style','text','BackgroundColor',[1 1 1],'string',{'RMS = '; num2str(dc_RMS(i))},'Units','Normal','Position',txtpos);
end
xlabel('Time (ms)');

[wavs_ds_rs{1}, wavs_fds_rs{1}, wavs_dc_rs{1}] = deal(wav);
for i = 1:length(fsdown) %resampling downsampled/decimated signals to higher sampling rate
    wavs_ds_rs{i+1,:} = resample(wavs_ds{i+1,:},fs,fsdown(i));
    wavs_fds_rs{i+1,:} = resample(wavs_fds{i+1,:},fs,fsdown(i));
    wavs_dc_rs{i+1,:} = resample(wavs_dc{i+1,:},fs,fsdown(i));
end

for i = 1:length(wavs_ds_rs)
    ds_rs_RMS(i) = RootMS(wavs_ds_rs{i},1);
    fds_rs_RMS(i) = RootMS(wavs_fds_rs{i},1);
    dc_rs_RMS(i) = RootMS(wavs_dc_rs{i},1);
end

figure('Color',[1 1 1],'NumberTitle','off','Name','Re-Upsampled signals','Position',scrz); %plotting upsampled signals
for i = 1:length(fsdown)+1
    lp(i) = subplot(6,2,i+(i-1));
    plot(tvec,wavs_fds_rs{i});
    axpos = get(lp(i),'Position');
    txtpos = [axpos(1)+axpos(3)*1.01 axpos(2)+axpos(4)/2 0.05 0.05];
    tboxl = uicontrol('style','text','BackgroundColor',[1 1 1],'string',{'RMS = '; num2str(fds_rs_RMS(i))},'Units','Normal','Position',txtpos);
    if i == length(fsdown)+1
        xlabel('Time (ms)');
    end
    ylabel('AU');
    rp(i) = subplot(6,2,i+(i-1)+1);
    plot(tvec,wavs_dc_rs{i});
    axpos = get(rp(i),'Position');
    txtpos = [axpos(1)+axpos(3)*1.01 axpos(2)+axpos(4)/2 0.05 0.05];
    tboxl = uicontrol('style','text','BackgroundColor',[1 1 1],'string',{'RMS = '; num2str(dc_rs_RMS(i))},'Units','Normal','Position',txtpos);
end
xlabel('Time (ms)');

%% Cell 3 - Noise and Averaging (Generating that function)
scrz = get(groot,'ScreenSize')./2;
l = 0.2;
amp = 0.1;
fs = 1000;
f = 15;
[tvec, wav] = BuildSin(f,fs,l,amp);

%y = (exp(-10.*tvec).*(sin(2*pi*10.*tvec).*(cos(2*pi*5.*tvec)+1)))/2; %This isn't working...

y =  (((sin(100.*tvec)).^3)./(40+(tvec-10)).^2).*1000;

gaussvec = normrnd(0,1,length(y),1000);

y_RMS = RootMS(y,1);
reps = [1 10 100 1000];
for i = 1:length(reps)
    
    gaussvecs{:,i} = normrnd(0,1,length(y),reps(i));
    
    for j = 1:reps(i)
        trials{i}(:,j) = y' + gaussvecs{i}(:,j);
    end
    
    recovered(i,:) = mean(trials{i},2);
    reco_RMS(i) = RootMS(recovered(i,:),1);
end

figure('Color',[1 1 1],'NumberTitle','off','Name','Noise & Averaging','Position',scrz); %plotting upsampled signals
for i = 1:length(reps)+1
    pp = subplot(length(reps)+1,1,i);
    axpos = get(pp,'Position');
    txtpos = [axpos(1)+axpos(3)*1.01 axpos(2)+axpos(4)/2 0.05 0.05];
    if i == length(reps)+1
        plot(tvec,y);
        tboxl = uicontrol('style','text','BackgroundColor',[1 1 1],'string',{'RMS = '; num2str(y_RMS)},'Units','Normal','Position',txtpos);
    else
        plot(tvec,recovered(i,:));
        tboxl = uicontrol('style','text','BackgroundColor',[1 1 1],'string',{'RMS = '; num2str(reco_RMS(i))},'Units','Normal','Position',txtpos);
    end
end