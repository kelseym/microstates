function trialData = generateWhiteNoise(trialData, passband, trialFreq)

    [channels, samples] = size(trialData);
    randData = randn(channels, samples)-0.5;
    % Bandpass to match original signal
    if ~numel(passband)==2
        error('Specify two element passband');
    end
    [b,a] = butter(9, passband/(trialFreq/2));
    filtRandData = filter(b,a,randData);
    trialData = filtRandData;

end

