function trialData = generateWhiteNoiseTrials(trialData, passband, trialFreq)

for i=1:length(trialData)
    [channels, samples] = size(trialData{i});
    randData = randn(channels, samples)-0.5;
    % Bandpass to match original signal
    if ~numel(passband)==2
        error('Specify two element passband');
    end
    [b,a] = butter(9, passband/(trialFreq{i}/2));
    filtRandData = filter(b,a,randData);
    trialData{i} = filtRandData;
end

end

