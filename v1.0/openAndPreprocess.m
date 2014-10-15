function [trialData, trialSize, trialFreq, numChan] = openAndPreprocess(filename, sensorList)
    %% Load ECoG data and pre-process
    cfg = [];
    cfg.datafile = filename;
    cfg.channels = sensorList;
    cfg.continuous = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [59 61; 119 121; 179 181];
    cfg.demean = 'yes';
    cfg.detrend = 'yes';
    % cfg.polyremoval = 'yes';
    % cfg.polyorder = 2;
    %cfg.preproc.baselinewindow = [-0.1 -.001];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [1.0 40.0];
    data = ft_preprocessing(cfg);

    % Grab important values from data
    numChan = length(data.label);
    trialData = data.trial{1};
    trialData = trialData(sensorList, :);
    trialTime = data.time;
    trialFreq = data.fsample;
    trialSize = size(trialData,2);
    trialSampleInfo = data.sampleinfo;
end
