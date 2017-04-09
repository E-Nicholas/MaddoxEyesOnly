function tvec = GetTime(fs,time,varargin)
% GetTime will return a time vector with the desired sampling rate and
% length. Sampling rate is ALWAYS samples per second.
% If only fs and a length are given returns from t(dt) to t(time).
%
% If additional inputs are given they will be processed as follows;
%
% tvec = GetTime(fs,prezero,postzero,units)
%
% Where the second input is the amount of time before 0, in seconds,
% and postzero is time after zero.
%
% A fouth optional input taken as power to set units of tvec (i.e. 3 = ms, 6 = us)
dt = 1/fs;
if isempty(varargin)
    tvec = dt:dt:time;
else
    base = 1;
    if length(varargin) > 1;
        base = 10^varargin{2};
    end
    tvec = -abs(time)*base:dt*base:varargin{1}*base;
end

end