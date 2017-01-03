function xFilt = jfilt(x,fs,filt_type,bandwidth,varargin)
% JFILT wraps the Butterworth low, high, and bandpass filters
%
%	INPUT
%       x:  Data to be filtered [n_samples x n_channels]
%       fs: Sampling rate of data
%       type:  Specify the filter type (low, high, pass)
%       bw:    Filter bandwidth (Cutoff freq for low,high), ([lo hi] for bw)
%       OPTIONAL
%           order: Filter order (Default = 4)
%
%	OUTPUT
%       xFilt: Filtered data
%
% John W. Miller
% 29-Jun-2016


% Key-value pair varargin
optional_inputs = {'order'}; default_values = {4};
[filt_order] = parseKeyValuePairs(varargin,optional_inputs,default_values);

% Check for NaNs
if any(sum(isnan(x)))
    warning('Detected NaNs in x, replacing w/ nanmean.')
    mask_nans = any(isnan(x));
    sub_val = nanmean(nanmean(x(:,mask_nans)));
    x((isnan(x))) = sub_val; % Kludge
end

% Which filter will we use?
switch lower(filt_type)
    case 'low'
        Wn = bandwidth/(fs/2);
        [b,a] = butter(filt_order,Wn,'low');
    case 'high'
        Wn = bandwidth/(fs/2);
        [b,a] = butter(filt_order,Wn,'high');
    case 'band'
        bandwidth = bandwidth/(fs/2);
        [b,a] = butter(filt_order,bandwidth);
    otherwise
        error('Incorrect filter specification. Options: low, high, band.')
end

% Perform the filter
xFilt = filtfilt(b,a,x);

end % End of main