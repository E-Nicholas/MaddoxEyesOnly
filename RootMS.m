%% Root-Mean-Squared amplitude
%Takes the square root... of the root mean
%Eric Nicholas 2107
function RMSvals = RootMS(signal,dim)
%This function needs at least one comment...
RMSvals = sqrt(MeanSq(signal,dim)); %Uh, Take the square root
end