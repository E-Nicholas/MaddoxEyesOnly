function [tvec, epoch] = BMEepoch(x,evt,fs,tmin,tmax)
% BMEepoch will epoch continuous data in matrix x with event data
% evt; evt following strture n x 2 where n is trials
% and the 2nd dimension is [indexvalue eventvalue] reference
% to the continuous data in x. fs is samples per second, tmin is time pre
% stimulus and tmax is time post stimulus for each epoch
dt = 1/fs;

prepoints = tmin/dt;
postpoints = tmax/dt;

idxarray = int32(-prepoints:1:postpoints);
evt_vals = unique(evt(:,2));

for i = 1:length(evt_vals)
    nevent(i) = length(find(evt(:,2) == evt_vals(i)));
end

epoch = zeros(length(idxarray),length(evt_vals),nevent(1));
for i = 1:length(evt_vals)
    evt_idx = evt(evt(:,2) == evt_vals(i),1);
    for j = 1:nevent(1)
        epoch(:,i,j) = x(idxarray+evt_idx(j));
    end
end
tvec = GetTime(fs,tmin,tmax);

end