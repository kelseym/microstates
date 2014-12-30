%% Plot sorted microstate template maps for a single subject while varing the number of allowed microstates

clear;

fileName = GetLocalDataFile();
outputDir = GetLocalOutputDirectory();
trialLength = 60;
trialOverlap = 0;
numMicrostates = 4;

% select and open preprocessed HCP MEG data file
load(fileName, 'data');

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


%% Open layout
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

data = ConcatenateTrials(data);

%% extract N global microstate templates across all trials
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'global';
globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);
PlotMicrostateTemplateSet(globalMicrostateTemplates{1}{1}, data.label, lay, 'Global Templates');

%% extract N local microstate templates across all trials
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'local';
localMicrostateTemplates = ExtractMicrostateTemplates(cfg);
PlotMicrostateTemplateSet(localMicrostateTemplates{1}{1}, data.label, lay, 'Local Templates');


%% extract N trial microstate templates across all trials
data = ConcatenateTrials(data);

cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'trial';
trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);
PlotMicrostateTemplateSet(trialMicrostateTemplates{1}{1}, data.label, lay, 'Trial Templates');










