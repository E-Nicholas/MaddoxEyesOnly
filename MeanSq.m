%% Mean Squared amplitude
%function for calculating the ROOTMEAN amplitude of a signal,
%takes signal and dimension as inputs
%Eric Nicholas - 2017 UR
function MS = MeanSq(signal,dim)
for i = 1:size(signal,dim)
    MS(i) = mean(signal(:,1) .^ 2);
end
end