function t = maketime(x,fs)
% MAKETIME creates a time vector the same length of X.
%
%	INPUT
%       x:  Data vector
%       fs: Sampling rate of X.
%
%	OUTPUT
%       t:  Time vector (in seconds) the same lengt of x
%
% John W. Miller
% 2016-01-14

t = ((0:length(x)-1)/fs)';

end % End of main