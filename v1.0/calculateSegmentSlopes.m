
function ft_pxx = calculateSegmentSlopes(ft_pxx, cfg)

% Check for required input
% ensure that the required options are present
cfg = ft_checkconfig(cfg, 'required', {'freqEndpoints'});
cfg = ft_checkconfig(cfg, 'required', {'fitFreq'});

% determine dimension order of powspctrm matrix
split = regexp(ft_pxx.dimord,'_','split');
chanDim = find(strcmp(split,'chan'));
timeDim = find(strcmp(split,'time'));
freqDim = find(strcmp(split,'freq'));

% FIXME: adapt to different dimension order
if ~strcmp(ft_pxx.dimord,'chan_freq_time')
    avgError('expected order of pxx to be chan_freq_time');
end

% determine the number of time intervals and channels.
numTimeInts = size(ft_pxx.powspctrm,timeDim);
numChan = size(ft_pxx.powspctrm,chanDim);

% determine number of spectrum endpoint to be considered
ft_pxx.freqEndpoints = cfg.freqEndpoints;
ft_pxx.fitFreq = cfg.fitFreq;
numFitFreqs = size(ft_pxx.fitFreq,1) ;

% we're looking for slopes in log space, so consider log10 of the freq axis
logFreq = log10(ft_pxx.freq);

detailedSlopes = zeros(numTimeInts, numChan, numFitFreqs, 3) ;
disp(sprintf('Starting slope calculation on %i core(s).', matlabpool('size')));
slopeCalc = tic;
parfor chan = 1:numChan
    chanSpectrum = squeeze(ft_pxx.powspctrm(chan, :, :));
    for timeInt = 1:numTimeInts
        timeChanSpectrum = squeeze(chanSpectrum(:,timeInt));
        logSpectrum = log10(timeChanSpectrum);
        for fitNum = 1:numFitFreqs
            f1 = ft_pxx.fitFreq(fitNum, 1);
            f2 = ft_pxx.fitFreq(fitNum, 2);
            indexSet = find((ft_pxx.freq >= f1) & (ft_pxx.freq <= f2)) ;
            if (numel(indexSet) >= 2)
                % Use least squares regression fit
                P = polyfit(logFreq(indexSet), logSpectrum(indexSet), 1) ;
                yLineFit = polyval(P, logFreq(indexSet)) ;
                slope = P(1);
                yIntercept = P(2);
                % measure average error between pdf and line fit
                avgError = abs(yLineFit - logSpectrum(indexSet));
                avgError = mean(avgError);
                detailedSlopes(timeInt, chan, fitNum, :) = [slope, yIntercept, avgError];
            end
         end
    end
end

ft_pxx.detailedSlopes = detailedSlopes;
ft_pxx.detailedSlopesDimOrder = 'timeInt_chan_fitFreq_stat';
ft_pxx.detailedSlopesStatDimOrder = 'slope_yIntercept_avgError';

toc(slopeCalc)
