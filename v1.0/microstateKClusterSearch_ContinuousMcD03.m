clear;
% if matlabpool('size') <= 1
%     matlabpool open
% end
lineColors = lines;close;

filename = 'D:\Projects\McDonnell\McD03 challenge files\McD03 2hour.EDF';
trialLabel = '2hr McD03';
sensorList = 1:32;

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
trialTime = data.time{1};
trialFreq = data.fsample;
trialSize = size(trialData,2);
trialSampleInfo = data.sampleinfo;

% restrict to 32 channels on grid 1 and the first 5 seconds for testing 
trialData = trialData(sensorList, :);
% %     %%%% Remove these lines to include full time course. From here,
%     trialTime = trialTime(1:2500);
%     trialData = trialData(sensorList, 1:2500);
%     numChan = size(trialData,1);
% %     %%%%% to here
trialSize = size(trialData,2);

%% GFP calculation
windowLength = 0;
stdDevFactor = 0;
[gfp, gfpPkLocs] = microstateGfpPeaks(trialData, trialSize, trialFreq, numChan, windowLength, stdDevFactor);
disp(['Found ' num2str(length(gfpPkLocs)) ' GFP local maxima in ' trialLabel]);

windowLength = 30;
stdDevFactor = 1;
[~, bigGfpPkLocs] = microstateGfpPeaks(trialData, trialSize, trialFreq, numChan, windowLength, stdDevFactor);
disp(['Found ' num2str(length(bigGfpPkLocs)) ' big GFP peaks ' trialLabel]);


%% Calculate N microstate template maps as the mean average of all member vpMaps
%  Track GEV - Global Explained Variance - for each N
%  Track per map and per number of number of maps N, for each trial
maxNumMicroStates = 32;
globalExVar = zeros(maxNumMicroStates,1);
sampleWindowLength = 300;
assignmentWindowLength = 60;

% Setup GEV plot
figure, hold on;
title('Template Quantity Selection');
ylabel('GEV');
xlabel('Number of Microstate Templates');
grid on;
xlim([1 maxNumMicroStates]);
h1=[];

for numMicrostates=1:maxNumMicroStates
    
    % Calculate N microstate template maps for each time segment using a sliding window
    % slidingWindowTemplates contains an NxMxD array, with N time samples, M sensors and D number of requested template maps
    [compressedSlidingWindowTemplates, templateStartIndices] = microstateSlidingWindowTemplates(trialData, trialFreq, gfpPkLocs, sampleWindowLength, assignmentWindowLength, numMicrostates);

    % Compute correlation coefficent between sliding templates and original signal
    templateCorrelations = microstaeGetTemplateCorrelations(trialData, compressedSlidingWindowTemplates, templateStartIndices);
    
    % Label each sample with 1 of N templates, corresponding to max correlation
    [maxCorr, maxCorrTemplIdx] = max(templateCorrelations,[],1);
    % Compute GEV
    numer = sumsqr(gfp.*maxCorr);
    denom = sumsqr(gfp);
    gev = numer/denom;
    globalExVar(numMicrostates) = gev;
    
    % plot GEV
    if ~isempty(h1)
        set(h1,'Visible','off');
    end

    h1 = plot(globalExVar(1:numMicrostates),'k.-','LineWidth',1);

end





