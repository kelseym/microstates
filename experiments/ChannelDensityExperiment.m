%% Extract microstate parameters from MEG scans
%   Reduce density of channels by removing a random set according to the densityFactor
%   densityFactor = 1 keeps all channels, densityFactor = 0.5 keeps half of the channels, etc.
clear;

numMicrostates = 3;

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
cfg.bpfreq = [1 40];
fullData = ft_preprocessing(cfg, data);
fullData = ConcatenateTrials(fullData);

numSensors = [];
md = [];
sd = [];
gr = [];
gs = [];


for densityFactor = 0.1:0.1:1


  % select reduced set of random channels
  numRoiSensors = ceil(length(fullData.label)*densityFactor);
  roiIndices = randperm(length(fullData.label), numRoiSensors);
  roiChannels = fullData.label(roiIndices);
  cfg = [];
  cfg.channel = roiChannels;
  data = ft_selectdata(cfg, fullData);


  %% Plot time series
  PlotTimeSeries(data, 0, 5, '');

  %% Extract GFP Peaks
  for trli=1:length(data.trial)
    [gfp{trli}, gfpPkLocs{trli}] = LocateGfpPeaks(data.trial{trli});
  end
  data.gfpPkLocs = gfpPkLocs;
  data.gfp = gfp;

  % Plot GFP
  startS = 0;
  endS = 5;
  pltSmpls = startS*data.fsample:endS*data.fsample;
  pltSmpls = floor(pltSmpls)+1;
  figure;
  plot(data.time{1}(pltSmpls), gfp{1}(pltSmpls),'b');
  title(['Global Field Power ' num2str(numRoiSensors) ' Sensors']);
  xlabel('Time (s)');
  ylabel('GFP');
  hold on;
  pltPksIndx = gfpPkLocs{1}(gfpPkLocs{1}<(5*data.fsample));
  plot(data.time{1}(pltPksIndx), gfp{1}(pltPksIndx),'r.');


  %% extract N microstate templates

  % dataStructs contains a cell array of fieldtrip data strutures - which
  % will be concatenated to derive microstate templates - just one for now
  dataStructs{1} = data;

  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataStructs;
  cfg.clustertrainingstyle = 'global';
  microstateTemplates = ExtractMicrostateTemplates(cfg);


  %% Plot Template Maps
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}, data.label, lay, [scanLabel num2str(numRoiSensors) ' Sensors']);

  %% partition data into N second (non-)overlaping trials
  cfg = [];
  cfg.length=10;
  cfg.overlap=0.0;
  for i=1:length(dataStructs)
    % Concatenate time series data end-to-end in a single trial
    dataStructs{i} = ConcatenateTrials(dataStructs{i});
    % Redistribute into new trial lengths
    dataStructs{i} = ft_redefinetrial(cfg, dataStructs{i});
  end

  %% find microstate sequence in electroneurophys data
  cfg = [];
  cfg.microstateTemplates = microstateTemplates{1}{1};
  for i=1:length(dataStructs)
    dataStructs{i} = AssignMicrostateLabels(cfg, dataStructs{i});
  end



  %% extract features from microstate sequence
  cfg = [];
  cfg.features = {'meanduration','stdduration','gfppeakrate','stdgfppeaks'};
  for i=1:length(dataStructs)
    dataStructs{i} = MeasureFeatures(cfg, dataStructs{i});
  end

  %% Plot microstate sequence
  cfg = [];
  cfg.trialindex = 1;
  cfg.starttime = 0;
  cfg.endtime = 5;
  figure;
  PlotMicrostateSequence(dataStructs{1}, cfg);

  %% Plot microstate features
  for i=1:length(dataStructs)
    data = dataStructs{i};
    fh = PlotFeatureXY(data, 'meanduration', 'stdduration',['Microstate Features ' num2str(numRoiSensors) ' Sensors']);
  end

  for i=1:length(dataStructs)
    data = dataStructs{i};
    fh = PlotFeatureXY(data, 'gfppeakrate','stdgfppeaks',['Microstate Features ' num2str(numRoiSensors) ' Sensors']);
  end
  
  numSensors(end + 1) = numRoiSensors;
  md(end+1) = mean(GetFeatureValue(data, 'meanduration'));
  sd(end+1) = mean(GetFeatureValue(data, 'stdduration'));
  gr(end+1) = mean(GetFeatureValue(data, 'gfppeakrate'));
  gs(end+1) = mean(GetFeatureValue(data, 'stdgfppeaks'));
  
end

%% plot features vs numSensors
figure;
plot(numSensors,md,'--*');
title(' Duration vs Sensor Count');
xlabel('Number of Sensors');
ylabel('Mean MS Duration');

figure;
plot(numSensors,sd,'--*');
title(' STD Duration vs Sensor Count');
xlabel('Number of Sensors');
ylabel('STD MS Duration');

figure;
plot(numSensors,gr,'--*');
title(' GFP Peak Rate vs Sensor Count');
xlabel('Number of Sensors');
ylabel('GFP Peak Rate (peaks per sec)');

figure;
plot(numSensors,gs,'--*');
title(' STD of GFPPeak  Rate vs Sensor Count');
xlabel('Number of Sensors');
ylabel('STD GFP Peak Rate');




