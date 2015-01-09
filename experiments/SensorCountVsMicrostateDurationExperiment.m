%% Vary the number of source sensors to check for microstate duration changes


clear;

numMicrostates = 4;
fileName = GetLocalDataFile();


% select and open preprocessed HCP MEG data file
load(fileName, 'data');
[~, scanLabel, ~] = fileparts(fileName);

% band filter preprocess
cfg = [];
cfg.continuous = 'yes';
cfg.bsfilter = 'yes';
cfg.bsfreq = [59 61; 119 121; 179 181];
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
rawData = ft_preprocessing(cfg, data);

allChannels = rawData.label;
avgMeanDuration = [];
avgGfpPeakRate = [];
numSensors = [];

% Reduce sensor count
for sensorCountIndex=1:10
  cfg = [];
  cfg.channel = allChannels(1:sensorCountIndex:length(allChannels));
  data = ft_preprocessing(cfg, rawData);

  %% extract N microstate templates

  % dataStructs contains a cell array of fieldtrip data strutures - which
  % will be concatenated to derive microstate templates - just one for now

  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = data;
  cfg.clustertrainingstyle = 'global';
  microstateTemplates = ExtractMicrostateTemplates(cfg);


  %% partition data into N second (non-)overlaping trials
  cfg = [];
  cfg.length=10;
  cfg.overlap=0.0;
  % Concatenate time series data end-to-end in a single trial
  data = ConcatenateTrials(data);
  % Redistribute into new trial lengths
  data = ft_redefinetrial(cfg, data);

  %% find microstate sequence in electroneurophys data
  cfg = [];
  cfg.microstateTemplates = microstateTemplates{1}{1};
  data = AssignMicrostateLabels(cfg, data);



  %% extract features from microstate sequence
  cfg = [];
  cfg.features = {'meanduration','gfppeakrate'};
  data = MeasureFeatures(cfg, data);

  avgMeanDuration(end+1) = mean(data.featurevalues{1});
  avgGfpPeakRate(end+1) = mean(data.featurevalues{2});
  numSensors(end+1) = length(data.label);
end

%% Plot results
figure;
plot(numSensors,avgMeanDuration,'.');
title('Microstate Duration vs Sensor Count');
xlabel('Number of Sensors');
ylabel('Mean Microstate Duration');
grid on;

figure;
plot(numSensors,avgGfpPeakRate,'.');
title('GFP Peak Rate vs Sensor Count');
xlabel('Number of Sensors');
ylabel('Mean GFP Peak Rate');
grid on;

