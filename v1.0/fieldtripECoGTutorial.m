clear;
%filename = 'D:\Projects\ECOG_Work\McDonnell\McD03_SWS_0113-0118.EDF'
filename = 'D:\Projects\ECOG_Work\McDonnell\McD03_wake_1726-173.edf'
%% Load ECoG data and pre-process
cfg = [];
cfg.dataset = filename;
cfg.continuous = 'yes';
% cfg.bsfilter = 'yes';
% cfg.bsfreq = [59 61; 119 121; 179 181];
cfg.demean = 'yes';
cfg.detrend = 'yes';
data = ft_preprocessing(cfg);

% %% visulally reject channels
% cfg = [];
% cfg.method = 'summary';
% data = ft_rejectvisual(cfg,data);


%% FT_FREQANALYSIS
cfg = [];
cfg.output = 'pow';
cfg.channel = 'all';
cfg.method = 'mtmconvol';
cfg.taper = 'hanning';

% compute log spaced fois
fMin = 0.2;
fMax = 200;
nFois = 512;
cfg.foi = logspace(log10(fMin),log10(fMax),2^floor(log2(nFois)));

analysisTimeWindow = 30; % time window = 10 sec
% cfg.t_ftimwin = vector 1 x numfoi, length of time window (in seconds)
cfg.t_ftimwin = ones(length(cfg.foi),1).*analysisTimeWindow;
analysisTimeStepSize = 30; % Step size used to slide time window
endTime = 300;
% cfg.toi = vector 1 x numtoi, the times on which the analysis windows should be centered (in seconds)
cfg.toi = (0.5*analysisTimeWindow):analysisTimeStepSize:(endTime-(0.5*analysisTimeWindow)); % time window "slides" from start(zero + half timeWindow size) to end(end- half timeWindow size) in step size increments

TFRhann = ft_freqanalysis(cfg,data);

% calculate mean across time dimension
timeAvgPSD = mean(TFRhann.powspctrm,3);
figure, loglog(TFRhann.freq, timeAvgPSD)
title(sprintf('Average Power Across All %i Second Intervals', analysisTimeWindow));
xlabel('f');
ylabel('Power per sensor');

% calculate mean across sensor(channel) dimension
sensorAvgPSD = squeeze(mean(TFRhann.powspctrm,1));
figure, loglog(TFRhann.freq, sensorAvgPSD)
title(sprintf('Average Power Across All Sensors'));
xlabel('f');
ylabel(sprintf('Power per %i second interval', analysisTimeWindow));

figure, semilogy(TFRhann.freq)
hold on
semilogy(cfg.foi,'r--')
legend('output','input')



