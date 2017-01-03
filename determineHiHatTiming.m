% DETERMINEHIHATTIMING
%
%
% John W. Miller
% 2016-01-14

% "Fluctuations of hi-hat timing and dynamics in a virtuoso drum track of a popular music recording."
% Rasanen et al., 2015

%% Load a song
pathToFile = fullfile(go('down'),'03 Dean Town.mp3');
[y,fs,t] = loadAudio(pathToFile);

%% Filter the audio
% Playing around with the cutoff frequency seems to improve detection quite a bit
yHiPass = jfilt(y,fs,'high',4000);

% Visualize the filtered audio
mask = and(t>=46,t<=90);
win_len = round(0.001*length(yHiPass(mask))); figure(3)
spectrogram(yHiPass(mask),win_len,round(0.01*win_len),[],fs,'yaxis')
set(gca,'yscale','log')

% Listen to the filtered audio
audio = audioplayer(yHiPass(mask),fs);
stop(audio), play(audio)

%% Threshold detection
good_idxs = detectThresholdCrossings(yHiPass,fs,'show_plot',0);

%% Create a click track

click_track = zeros(size(y));
width = 3;
for ii = 1:length(good_idxs)-1
    click_track(good_idxs(ii):good_idxs(ii)+width) =...
        max(yHiPass(good_idxs(ii):good_idxs(ii+1)));%.*sind((2*pi*1)*(0:width));
end, ii = ii + 1;
click_track(good_idxs(ii)) = max(yHiPass(good_idxs(ii):end));

    % Visualize
figure(33), hold on
plot(t(mask),abs(yHiPass(mask)))
plot(t(mask),click_track(mask),'r.-')
    
%%    % Listen to the click track    
audio = audioplayer(10*click_track(mask),fs);
% audio = audioplayer(10*click_track(mask)+yHiPass(mask),fs);
% audio = audioplayer(10*click_track(mask)+0.5*y(mask),fs);
%audio = audioplayer(10*click_track(mask),fs);
stop(audio),play(audio)








%end % End of main
