%% BME Laboratory exercise 2 - Epoching and Averaging EEG data

clear;

%% Importing and loading data

scrz = get(groot,'ScreenSize')./2;
load('lab2_data_matlab.mat');

tvec = GetTime(fs,1);

figure('Color',[1 1 1],'NumberTitle','off','Name','First Second of Example Data','Position',scrz);
plot(tvec,raw(1:length(tvec)));
ylabel('Voltage (V)'); xlabel('Time (s)');
title('First Second of Example Data');
%% Starting with Epoching...

% Pondering the events, a good many, we are asked if they are structured in
% any meaningful way... well, let's see.

%Lets just look at the events in order and see if there's any structure
figure('Color',[1 1 1],'NumberTitle','off','Name','First 120 events','Position',scrz);
plot(events(1:120,2))
set(gca,'XTick',0:5:120,'ylim',[0.75 2.25],'YTick',0:1:2,'YTickLabel',{'2 - Right Ear' '1 - Left Ear'});
ylabel('Event Value'); xlabel('Event Number');
title('The First 120 Event Values');
% Looks pretty random from here... but we can dig into how often each
% repeats and to what extent.
left_reps = []; %init
right_reps = []; %init
prevtrial = events(1,2); %Intialize prevtrial trial tracking variable to track trials
count = 1; %Initialize counter, all sequences contain at least one stim...
stepfcn = 1;
for i = 2:length(events)  %Just quick loop-de-loop to count how many times
    if events(i,2) == 1   %a trigger value appears in a row, and how many
        if prevtrial == 1 %repititions are present in the
            stepfcn(i) = stepfcn(i-1) + 1;
            count = count + 1;
            prevtrial = events(i,2);
        else
            stepfcn(i) = 1;
            right_reps = [right_reps count];
            count = 1;
            prevtrial = events(i,2);
        end
    else
        if prevtrial == 2
            stepfcn(i) = stepfcn(i-1) - 1;
            count = count + 1;
            prevtrial = events(i,2);
        else
            stepfcn(i) = -1;
            left_reps = [left_reps count];
            count = 1;
            prevtrial = events(i,2);
        end
    end
end

maxrepeats_ones = max(left_reps) % Both matrices containing the number of sequences for each
maxrepeats_twos = max(right_reps) % trigger value are the same size 5599 sequences total, and
                               % both have max values of 7.
                               
thresh = 0;                    % To generate a plot showing the sequences
aboveLine = (stepfcn>=thresh); % of each event type in order, nicely with different
bottomLine = stepfcn;          % colors for each event value we separate the data
topLine = stepfcn;             % into two vectors and then set the values of one or
bottomLine(aboveLine) = 0;     % the other to 0 when the value is above or below thresh
topLine(~aboveLine) = 0;       % I constructed the stepfcn vector with this plotting method in mind

% The following plot shows the sequence of event repeats, where each point
% represents the number of repeated events in the last sequence (showing the first 60 sequences).
figure('Color',[1 1 1],'NumberTitle','off','Name','Repeated Event Sequences (first 60)','Position',scrz.*2);
subplot(2,1,1);
plot(left_reps(1:300),'LineWidth',2); hold on; %This plot suggests a trend for the different trigger values
plot(right_reps(1:300),'LineWidth',2); grid on; %There seem to be more blue peaks at the sequence number of 6
set(gca,'ylim',[0 7],'XTick',0:5:300);  %and more red peaks at lower sequence numbers, we need to see the
legend('Left Ear Click','Right Ear Click','Location','northeast') % relative number of each repeat sequence for both events
ylabel('Number of Repeats'); xlabel('Sequence Number');
title('Repeated Event Sequences, overlaid(first 300 sequences of each event)');
subplot(2,1,2);
plot(bottomLine(1:400),'r'); hold on;
plot(topLine(1:400),'b');
set(gca,'YTick',-7:1:7,'YTickLabel',{'7' '6' '5' '4' '3' '2' '1' '0' '1' '2' '3' '4' '5' '6' '7'});
ylabel('Number of Repeats'); xlabel('Sequence Number');
legend('Right Ear Click','Left Ear Click','Location','northeast');
title('Repeated Event Sequences, in order (first 400 sequences)');

nreps = unique(left_reps);

for i = 1:length(nreps)
    nones_reps(i) = length(find(left_reps == nreps(i)));
    ntwos_reps(i) = length(find(right_reps == nreps(i)));
end

%So, it looks like there's a purposeful structure to the number of repeats
%of each repeat-sequence for the different event values. Event #2 (right ear) has more
%sequences with 4 repeated right-ear-clicks. Event 1 (left ear) has far more repeats of 2, and
%repeats of 6 consecutive clicks to the left ear.
figure('Color',[1 1 1],'NumberTitle','off','Name','Number of repeated event sequences','Position',scrz);
bar3([nones_reps' ntwos_reps']);
ylabel('Number of Repeats'); xlabel('Event Type'); zlabel('Numer of Sequences');
legend('Left Ear Click','Right Ear Click','Location','northeast');

%% Staring With Epoching... now the epoching

tmin = .01;
tmax = .02;

[tvec, epoch_prebase] = BMEepoch(raw,events,fs,tmin,tmax);

trange = [-0.05 0];
epoch = BMEbaseline(epoch_prebase,tvec,trange); %Baseline correction, because baselines crave discipline

event_mean = mean(epoch,3);
event_err = std(epoch,0,3)/sqrt(length(epoch));
mean_scaled = event_mean .* 10^6; %Scale to a reasonable unit
err_scaled = event_err .* 10^6;
err_patch = {mean_scaled+(-1.*err_scaled) mean_scaled+err_scaled};
tvec = GetTime(fs,tmin,tmax,3); % Get a new time vector with units in ms for plotting

%PlotIt
figure('Color',[1 1 1],'NumberTitle','off','Name','Average ABR Response','Position',scrz);
patch([tvec fliplr(tvec)],[err_patch{1}(:,1)' fliplr(err_patch{2}(:,1)')],[0.2 1 0.8],'EdgeColor',[0.1 0.3 0.8],'FaceColor',[0.9 0.9 0.9],'EdgeAlpha',0.5); hold on;
patch([tvec fliplr(tvec)],[err_patch{1}(:,2)' fliplr(err_patch{2}(:,2)')],[0.8 1 0.2],'EdgeColor',[0.8 0.2 0.2],'FaceColor',[0.9 0.9 0.9],'EdgeAlpha',0.5);
plot(tvec,zeros(length(tvec)),'--','color',[0.6 0.6 0.6]);
p = plot(tvec,mean_scaled,'LineWidth',1.5);
%Annotations
text(1.95,0.17,'I','FontSize',18,'Color',[0 0.4 0.8]);
text(2.9,0.08,'II','FontSize',18,'Color',[0 0.4 0.8]);
text(4,0.15,'III','FontSize',18,'Color',[0 0.4 0.8]);
text(6,0.61,'V','FontSize',18,'Color',[0 0.4 0.8]);
text(8.4,0.3,'VI','FontSize',18,'Color',[0 0.4 0.8]);
text(3.8,0.32,'III','FontSize',18,'Color',[0.8 0.4 0]);
text(5.1,0.6,'IV','FontSize',18,'Color',[0.8 0.4 0]);
text(6.2,0.92,'V','FontSize',18,'Color',[0.8 0.4 0]);
text(8.4,0.45,'VI','FontSize',18,'Color',[0.8 0.4 0]);
%Finishing Touhces
set(gca,'xlim',[-5 10]);
ys = get(gca,'ylim');
plot([0 0],ys,'k--');
set(gca,'ylim',ys,'XTick',-5:1:10);
ylabel('Voltage (\muV)'); xlabel('Time (ms)');
legend(p,'Left Ear Click','Right Ear Click','Location','northeast');
title('Mean ABR - Left vs Right Ear');

%% Plotting signal and noise and estimating SNR
% This cell relies on variables declared in the previous cell, please
% evaluate the previous cell.
%
% Question #1. Yes, it seems the signal is larger than the noise.
%
% Even vs Odd trial splitting
odd_idx = find(mod(1:1:length(epoch),2) == 1);
even_idx = find(mod(1:1:length(epoch),2) == 0);
odd_mean = mean(epoch(:,1,odd_idx),3).* 10^6;
even_mean = mean(epoch(:,1,even_idx),3).* 10^6;

oddeven_splusn = mean([odd_mean even_mean],2);
oddeven_noise = mean([odd_mean (-1.*even_mean)],2);
%
% First half vs second hald splitting
first_half_idx = 1:1:floor(length(epoch)/2);
second_half_idx = first_half_idx(end):1:length(epoch);
first_half_mean = mean(epoch(:,1,first_half_idx),3).* 10^6;
second_half_mean = mean(epoch(:,1,second_half_idx),3).* 10^6;

halves_mean = mean([first_half_mean second_half_mean],2);
halves_noise = mean([first_half_mean (-1.*second_half_mean)],2);
%
% Random split of trials
rand_idx = randperm(length(epoch));
rand_first_idx = rand_idx(1:1:floor(length(epoch)/2));
rand_second_idx = rand_idx(length(rand_first_idx)+1:1:length(rand_idx));
rand_first_mean = mean(epoch(:,1,rand_first_idx),3).* 10^6;
rand_second_mean = mean(epoch(:,1,rand_second_idx),3).* 10^6;

rand_mean = mean([rand_first_mean rand_second_mean],2);
rand_noise = mean([rand_first_mean (-1.*rand_second_mean)],2);
%

%Question #5, estimation of SNR of left-ear responses using three trial
%splitting methods
evenodd_SNR = 10*log10((MeanSq(oddeven_splusn,2)-MeanSq(oddeven_noise,2))/MeanSq(oddeven_noise,2))

halves_SNR = 10*log10((MeanSq(halves_mean,2)-MeanSq(halves_noise,2))/MeanSq(halves_noise,2))

random_SNR = 10*log10((MeanSq(rand_mean,2)-MeanSq(rand_noise,2))/MeanSq(rand_noise,2))

%Plot Even vs Odd Trials
figure('Color',[1 1 1],'NumberTitle','off','Name','Odds vs Evens','Position',scrz)
subplot(2,1,1)
plot(tvec,odd_mean); hold on; plot(tvec,even_mean)
plot(tvec,zeros(length(tvec)),'--','color',[0.6 0.6 0.6]);
ys = get(gca,'ylim');
plot([0 0],ys,'k--');
ylabel('Voltage (\muV)'); xlabel('Time (ms)');
legend('Odd Trials','Even Trials','Location','northeast');
title('Signal and Noise - Odd vs Even Trials');
subplot(2,1,2)
plot(tvec,oddeven_splusn,'color',[0.8 0.4 0.6]); hold on; plot(tvec,oddeven_noise,'color',[0.2 0.8 0.2]);
plot(tvec,zeros(length(tvec)),'--','color',[0.6 0.6 0.6]);
text(5,-1,['SNR = ' num2str(evenodd_SNR)],'FontSize',14);
ys = get(gca,'ylim');
plot([0 0],ys,'k--');
ylabel('Voltage (\muV)'); xlabel('Time (ms)');
legend('Signal+Noise','Noise Estimate','Location','northeast');
%Qualitatively poor separation bewtween signal and noise, particularly
%between t = 2-10 ms
%
%Plot First Half vs Second Half of trials
figure('Color',[1 1 1],'NumberTitle','off','Name','First Half vs Second Half','Position',scrz)
subplot(2,1,1)
plot(tvec,first_half_mean); hold on; plot(tvec,second_half_mean)
plot(tvec,zeros(length(tvec)),'--','color',[0.6 0.6 0.6]);
ys = get(gca,'ylim');
plot([0 0],ys,'k--');
ylabel('Voltage (\muV)'); xlabel('Time (ms)');
legend('First Half Trials','Second Half Trials','Location','northeast');
title('Signal and Noise - First Half vs Second Half Trials');
subplot(2,1,2)
plot(tvec,halves_mean,'color',[0.8 0.4 0.6]); hold on; plot(tvec,halves_noise,'color',[0.2 0.8 0.2]);
plot(tvec,zeros(length(tvec)),'--','color',[0.6 0.6 0.6]);
text(5,-1,['SNR = ' num2str(halves_SNR)],'FontSize',14);
ys = get(gca,'ylim');
plot([0 0],ys,'k--');
ylabel('Voltage (\muV)'); xlabel('Time (ms)');
legend('Signal+Noise','Noise Estimate','Location','northeast');
%Qualitatively reasonable separation between signal and noise
%
%Plot Trials Randomly split in half
figure('Color',[1 1 1],'NumberTitle','off','Name','Rand First Half vs Rand Second Half','Position',scrz)
subplot(2,1,1)
plot(tvec,rand_first_mean); hold on; plot(tvec,rand_second_mean)
plot(tvec,zeros(length(tvec)),'--','color',[0.6 0.6 0.6]);
ys = get(gca,'ylim');
plot([0 0],ys,'k--');
ylabel('Voltage (\muV)'); xlabel('Time (ms)');
title('Signal and Noise - Random 1/2 vs Remaining 1/2 of Trials');
legend('Random Trials','Remaining Trials','Location','northeast');
subplot(2,1,2)
plot(tvec,rand_mean,'color',[0.8 0.4 0.6]); hold on; plot(tvec,rand_noise,'color',[0.2 0.8 0.2]);
plot(tvec,zeros(length(tvec)),'--','color',[0.6 0.6 0.6]);
text(5,-1,['SNR = ' num2str(random_SNR)],'FontSize',14);
ys = get(gca,'ylim');
plot([0 0],ys,'k--');
ylabel('Voltage (\muV)'); xlabel('Time (ms)');
legend('Signal+Noise','Noise Estimate','Location','northeast');
%Looks like a good separation of signal and noise, looking at t < 0 gives
%particular confidence as the noise is fairly low through this period


%Question #6, The Even odd split is substantially worse than taking random
%trials, or splitting the trials in half based on their temporal order.
%This is because, I'm speculating but have ideas to show, there was a
%somewhat non-random structure to the trial order. I would like to generate
%a plot showing the probability of repeated same-ear clicks in the even and
%odd trial distributions.
