function tvec = GetTime(fs,time,varargin)
% GetTime will return a time vector with the desired sampling rate and
% length. Sampling rate is ALWAYS samples per second.
% If only fs and a length are given returns from t(dt) to t(time).
% If additional inputs are given they will be processed as follows,
% tvec = GetTime(fs,prezero,postzero,units)
% 
    dt = 1/fs;
if isempty(varargin)
    tvec = dt:dt:time;
else
    tvec = -abs(time):dt:varargin{1};
end

end