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
%% Starting with Epoching... dem events yo

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
%sequences with 4 repeated 2's. Event 1 (left ear) has far more repeats of 2, and
%repeats of 6 consecutive clicks to the left ear.
figure('Color',[1 1 1],'NumberTitle','off','Name','Number of repeated event sequences','Position',scrz);
bar3([nones_reps' ntwos_reps']);
ylabel('Number of Repeats'); xlabel('Event Type'); zlabel('Numer of Sequences');


%% Staring With Epoching, now the epoching

tmin = .01;
tmax = .02;

[tvec, epoch_prebase] = BMEepoch(raw,events,fs,tmin,tmax);

trange = [-0.05 0];
epoch = BMEbaseline(epoch_prebase,tvec,trange);

event_mean = mean(epoch,3);
mean_scaled = event_mean .* 10^6;

tvec = GetTime(fs,tmin,tmax,3); % Get a new time vector with units in ms for plotting
figure('Color',[1 1 1],'NumberTitle','off','Name','Average ABR Response','Position',scrz); 
plot(tvec,mean_scaled,'LineWidth',1.5); hold on;
plot(tvec,zeros(length(tvec)),'--','color',[0.6 0.6 0.6]);
set(gca,'xlim',[-5 10]);
ys = get(gca,'ylim');
plot([0 0],ys,'k--');
set(gca,'ylim',ys,'XTick',-5:1:10);
ylabel('Voltage (\muV)'); xlabel('Time (ms)');
legend('Left Ear Click','Right Ear Click','Location','northeast');


