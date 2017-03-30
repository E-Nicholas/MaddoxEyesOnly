%% Mean Squared amplitude
%function for calculating the ROOTMEAN amplitude of a signal,
%takes signal and dimension as inputs
%Eric Nicholas - UR
function MS = MeanSq(signal,dim)
for i = 1:size(signal,dim)
    MS(i) = mean(signal(i,:) .^ 2);
end
end