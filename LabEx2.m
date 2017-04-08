%% BME Laboratory exercise 2 - Epoching and Averaging EEG data

clear;

%% Importing and loading data

scrz = get(groot,'ScreenSize')./2;
load('lab2_data_matlab.mat');

tvec = GetTime(fs,1);

plot(tvec,raw(1:length(tvec)));

%% Starting with Epoching... dem events yo

% Pondering the events, a good many, we are asked if they are structured in
% any meaningful way... well, let's see.
howbig = size(events)
% lots down the first dimension, those are our trials, what are the two
% values in the second
peek = events(1:10,:)
%the first clearly looks like an index position, and the second is our
%event

%Lets just look at the events in order and see if there's any structure
figure('Color',[1 1 1],'NumberTitle','off','Name','First 120 events','Position',scrz);
plot(events(1:120,2))
set(gca,'XTick',0:5:120,'ylim',[0.75 2.25],'YTick',0:1:2);
ylabel('Event Value'); xlabel('Event Number');
title('The First 120 Event Values');
% Looks pretty random... we can dig into how often each repeats and to what
% extent...
onereps = []; %init
tworeps = []; %init
prevtrial = events(1,2); %Intialize prevtrial trial tracking variable to track trials
count = 1; %Initialize counter, all sequences contain at least one stim...
stepfcn = 1;
for i = 2:length(events)  %Just quick loop-de-loop to count how many times
    if events(i,2) == 1   %a trigger value appears in a row each time it
        if prevtrial == 1 %appears
            stepfcn(i) = stepfcn(i-1) + 1;
            count = count + 1;
            prevtrial = events(i,2);
        else
            stepfcn(i) = 1;
            tworeps = [tworeps count];
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
            onereps = [onereps count];
            count = 1;
            prevtrial = events(i,2);
        end
    end
end

max(onereps) %Both have a max number of repeats of 7
max(tworeps)

thresh = 0;
aboveLine = (stepfcn>=thresh);
bottomLine = stepfcn;
topLine = stepfcn;
bottomLine(aboveLine) = 0;
topLine(~aboveLine) = 0;

% The following plot shows the sequence of event repeats, where each point
% represents the number of repeated events in the last sequence (showing the first 60 sequences).
figure('Color',[1 1 1],'NumberTitle','off','Name','Repeated Event Sequences (first 60)','Position',scrz.*2);
subplot(2,1,1)
plot(onereps(1:200)); hold on; %This plot suggests the number of repeated trials for
plot(tworeps(1:200)); grid on; %Each trigger value follow a similar structure
set(gca,'ylim',[0 7],'XTick',0:5:200);  %which also appears fairly random
legend('Event 1','Event 2','Location','northeast')
ylabel('Number of Repeats'); xlabel('Sequence Number');
title('Repeated Event Sequences, overlaid(first 200 of each)');
subplot(2,1,2)
plot(bottomLine(1:400),'r'); hold on;
plot(topLine(1:400),'b');
set(gca,'YTick',-7:1:7,'YTickLabel',{'7' '6' '5' '4' '3' '2' '1' '0' '1' '2' '3' '4' '5' '6' '7'});
ylabel('Number of Repeats'); xlabel('Sequence Number');
legend('Event 1','Event 2','Location','northeast')
title('Repeated Event Sequences, in order (first 60)');

nreps = unique(onereps);

for i = 1:length(nreps)
    nones_reps(i) = length(find(onereps == nreps(i)));
    ntwos_reps(i) = length(find(tworeps == nreps(i)));
end

%Each trigger value has the same number of repeated sequences
%across the experiment. So this can't be totally random
figure('Color',[1 1 1],'NumberTitle','off','Name','Number of repeated event sequences','Position',scrz);
bar3([nones_reps' ntwos_reps']);
ylabel('Number of Repeats'); xlabel('Event Type'); zlabel('Numer of Sequences');


%% Staring With Epoching, now the epoching















