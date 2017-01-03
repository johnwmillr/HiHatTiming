function good_idxs = detectThresholdCrossings(y_hipassed,fs,varargin)
% DETECTTHRESHOLDCROSSINGS returns the indices of each threshold crossing in the
% specified audio signal.
%
%	INPUT
%       y_hipassed: Audio signal after it has been hi-pass filtered.
%       fs: Sampling rate of the original singal.
%       OPTIONAL
%           show_plot: (bool) Do you want to see a plot or not?
%
%	OUTPUT
%       good_idxs: Indices for each threshold crossing.
%
% John W. Miller
% 03-Jan-2017

% Key-value pair varargin
optional_inputs = {'show_plot'}; default_values = {false};
[show_plot] = parseKeyValuePairs(varargin,optional_inputs,default_values);

%% Filtering
% Filter the signal, preparing it for detecting threshold crossings
yfilt = abs(y_hipassed);
yfilt = detrend(lopass(abs(dif2(yfilt)),fs,25));
[mew, sig] = deal(mean(yfilt), std(yfilt));

% User should play around with different values for optimal threshold detection
threshold = mew + 0.02*sig;
dead_time_after_negative_crossing = 0.001; % seconds

%% Threshold detection
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

%% Visualize (Optional)
if show_plot
    figure(11), hold off
    t = maketime(yfilt,fs);
    plot(t,yfilt), xlabel('Time (s)','fontsize',FS), hold on
    line(xlim,threshold*[1 1],'color','r','linewidth',1);    
    
    plot(t(pos_idxs),threshold,'rx')
    plot(t(neg_idxs),threshold,'ko')
    plot(t(good_idxs),threshold,'go')
    
end

end % End of main