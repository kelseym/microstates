%% Extract microstate parameters from MEG scans
clear;

numMicrostates = 4;
fileName = '/Users/Kelsey/Projects/EON/MEG 20 subjects/hcp_microstate_data_restin/105923_MEG_3-Restin_rmegpreproc.mat';


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

% concatenate time series data end-to-end in a single trial
data = ConcatenateTrials(data);

%% Plot time series
PlotTimeSeries(data, 0, 2, '');

%% extract N microstate templates

% dataStructs contains a cell array of fieldtrip data strutures - which
% will be concatenated to derive microstate templates - just one for now
dataStructs{1} = data;

cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = dataStructs;
microstateTemplates = ExtractMicrostateTemplates(cfg);


%% Plot Template Maps
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
fh = PlotMicrostateTemplateSet(microstateTemplates, data.label, lay, scanLabel);

%% partition data into N second (non-)overlaping trials
cfg = [];
cfg.length=10;
cfg.overlap=0.0;
for i=1:length(dataStructs)
  dataStructs{i} = ft_redefinetrial(cfg, dataStructs{i});
end
  
%% find microstate sequence in electroneurophys data
cfg = [];
cfg.microstateTemplates = microstateTemplates;
for i=1:length(dataStructs)
  dataStructs{i} = AssignMicrostateLabels(cfg, dataStructs{i});
end



%% extract features from microstate sequence
cfg = [];
cfg.features = {'meanduration','stdduration','gfppeakrate','stdgfppeaks'};
for i=1:length(dataStructs)
  dataStructs{i} = MeasureFeatures(cfg, dataStructs{i});
end

%% Plot microstate features
for i=1:length(dataStructs)
  data = dataStructs{i};
  PlotFeatureXY(data, 'meanduration', 'stdduration');
end



