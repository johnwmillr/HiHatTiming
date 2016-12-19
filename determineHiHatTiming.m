% DETERMINEHIHATTIMING
%
%
% John W. Miller
% 2016-01-14

% "Fluctuations of hi-hat timing and dynamics in a virtuoso drum track of a popular music recording."
% Rasanen et al., 2015

%% Load the data
pathToData = go('down');
filename = '03 Dean Town.mp3';
% filename = 'Michael McDonald  -  I Keep Forgettin''.mp3';
% filename = '1-19 Human Nature.mp3';
% filename = '01 Giant Steps.mp3';
% filename = '04 Golden Lady.mp3';
[y,fs] = audioread([pathToData filesep filename]);
y = mean(y,2); % Make it mono
t = maketime(y,fs);

%% Listen
audio = audioplayer(y,fs);
play(audio), pause(5), stop(audio)

%% Visualize
mask = and(t>=46,t<=90);
win_len = round(0.005*length(y(mask)));
figure(3), spectrogram(y(mask),win_len,round(0.01*win_len),[],fs,'yaxis'), ylim([250 16e3])
set(gca,'yscale','log')

audio = audioplayer(y(find(mask==1,1,'first'):end),fs);
play(audio), pause(5), stop(audio)

%% Filter
cutoff = 4000; % Playing around with the cutoff frequency seems to improve detection quite a bit

yHiPass = jfilt(y,fs,'high',cutoff);

% 
% Wn = cutoff/(fs/2);
% [bb,aa] = butter(50,Wn,'high');
% yHiPass = submean(normalize(filtfilt(bb,aa,y),mm(y)));

% Re-visualize
mask = and(t>=46,t<=90);
win_len = round(0.001*length(yHiPass(mask)));
figure(3)
spectrogram(yHiPass(mask),win_len,round(0.01*win_len),[],fs,'yaxis'), %ylim([250 17e3])
set(gca,'yscale','log')

audio = audioplayer(yHiPass(mask),fs);
stop(audio), play(audio)

%% Threshold detection
yfilt = abs(yHiPass);
yfilt = detrend(lopass(abs(dif2(yfilt)),fs,25));
% [bb,aa] = butter(20,500/(fs/2),'high');
% yfilt = filtfilt(bb,aa,yfilt);
[mew, sig] = deal(mean(yfilt), std(yfilt));
threshold = 0.02*sig; % Signal must be n_ standard deviations above the mean
dead_time_after_negative_crossing = 0.001; % s
% threshold = 1.25*sig; % Signal must be n_ standard deviations above the mean
% dead_time_after_negative_crossing = 0.025; % s

    % Visualize
figure(11), hold off
plot(t(mask),yfilt(mask)), xlabel('Time (s)','fontsize',FS), hold on
line(xlim,threshold*[1 1],'color','r','linewidth',2)

% Threshold crossings
over_threshold = yfilt > threshold;
threshold_crossings = [0; diff(over_threshold)];

    % The indices where the data crossed from below to above the threshold
pos_idxs = find(threshold_crossings == 1);
neg_idxs = find(threshold_crossings == -1);

    % Number of indicies to skip over after a negative crossing
blanked_idxs = bsxfun(@plus,neg_idxs,0:(round(dead_time_after_negative_crossing*fs)));
    % Include the positive crossings that didn't come too soon after a negative crossing
good_idxs = setdiff(pos_idxs,blanked_idxs);

plot(t(pos_idxs),threshold,'rx')
plot(t(neg_idxs),threshold,'ko')
plot(t(good_idxs),threshold,'go')

xlim(t([find(mask==1,1,'first') find(mask==1,1,'last')]))

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
