%% Extract microstate parameters from MEG scans
clear;

numMicrostates = 4;
[dataFileName, headModelFileName, sourceModelFileName] = GetLocalDataFileWithAnatomy();

% Load head and source models from .mat files
load(headModelFileName, 'headmodel');
load(sourceModelFileName, 'sourcemodel2d');

% select and open preprocessed HCP MEG data file
load(dataFileName, 'data');
[~, scanLabel, ~] = fileparts(dataFileName);

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

%% extract N microstate templates
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


%% Setup cfg structure for SPRecon
cfg=[];
cfg.sourcemodel2d = sourcemodel2d;
cfg.headmodel = headmodel;
cfg.grad = data.hdr.grad;
cfg.MicrostateLabels = data.label;
cfg.MicrostateTopo = microstateTemplates{1}{1};
MEGmicrostateSPRecon(cfg);




