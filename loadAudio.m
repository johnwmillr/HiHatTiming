function [y,fs,t] = loadAudio(pathToFile)
% LOADAUDIO
%
%	INPUT
%       pathToFile: Full path (including file name) to the audio file.
%
%
%	OUTPUT
%       y:  Audio file
%       fs: Sampling rate
%       t:  Time vector (s)
%
% John W. Miller
% 24-Dec-2016

% Load the data
[y,fs] = audioread(pathToFile);
y = mean(y,2); % Make it mono
t = maketime(y,fs);

if 1
    
    % Listen
    audio = audioplayer(y,fs);
    play(audio), pause(5), stop(audio)
    
    % Visualize
    mask = and(t>=46,t<=90);
    win_len = round(0.005*length(y(mask)));
    figure(3), spectrogram(y(mask),win_len,round(0.01*win_len),[],fs,'yaxis'), ylim([250 16e3])
    set(gca,'yscale','log')
    
    % Listen
    audio = audioplayer(y(find(mask==1,1,'first'):end),fs);
    play(audio), pause(5), stop(audio)
end