%% Extract microstate parameters from MEG scans
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
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg, data);

data = ConcatenateTrials(data);

%% Plot time series
PlotTimeSeries(data, 0, 5, '');

%% Plot GFP
[gfp, gfpPkLocs] = LocateGfpPeaks(data.trial{1});
startS = 0;
endS = 5;
pltSmpls = startS*data.fsample:endS*data.fsample;
pltSmpls = floor(pltSmpls)+1;
figure;
plot(data.time{1}(pltSmpls), gfp(pltSmpls),'b');
title(['Global Field Power']);
xlabel('Time (s)');
ylabel('GFP');
hold on;
pltPksIndx = gfpPkLocs(gfpPkLocs<(5*data.fsample));
plot(data.time{1}(pltPksIndx), gfp(pltPksIndx),'r.');


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
fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}, data.label, lay, scanLabel);

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
PlotMicrostateSequence(dataStructs{1}, cfg);

%% Plot microstate features
for i=1:length(dataStructs)
  data = dataStructs{i};
  fh = PlotFeatureXY(data, 'meanduration', 'stdduration','Microstate Features');
end

for i=1:length(dataStructs)
  data = dataStructs{i};
  fh = PlotFeatureXY(data, 'gfppeakrate','stdgfppeaks','Microstate Features');
end



