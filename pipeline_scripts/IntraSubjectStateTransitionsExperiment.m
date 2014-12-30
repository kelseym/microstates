

clear;


fileName = GetLocalDataFile();
outputDir = GetLocalOutputDirectory();
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


%% extract and plot N global microstate templates
data = ConcatenateTrials(data);
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'global';
microstateTemplates = ExtractMicrostateTemplates(cfg);
data.microstateTemplates = microstateTemplates{1};
% find microstate sequence in electroneurophys data
cfg = [];
cfg.microstateTemplates = data.microstateTemplates{1};
data = AssignMicrostateLabels(cfg, data);
% compute features
cfg = [];
cfg.features = {'statetransitions'};
data = MeasureFeatures(cfg, data);

% Open layout
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

% Plot microstate transistions
transistionFeatureIndex = strcmp(data.featurelabels, 'statetransitions');
transistionMatrix = data.featurevalues{transistionFeatureIndex}{1};
fh = PlotMicrostateTransistionMatrix(data.microstateTemplates{1}, data.label, lay, transistionMatrix);
set(fh,'Name','Global Microstates');

%% Extract and plot microstates for each T second interval
intervalLength = 60;
cfg = [];
cfg.length=intervalLength;
cfg.overlap=0.5;
data = ft_redefinetrial(cfg, data);
  
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'trial';
microstateTemplates = ExtractMicrostateTemplates(cfg);
data.microstateTemplates = microstateTemplates{1};
% find microstate sequence in electroneurophys data
cfg = [];
cfg.microstateTemplates = data.microstateTemplates{1};
data = AssignMicrostateLabels(cfg, data);
% compute features
cfg = [];
cfg.features = {'statetransitions'};
data = MeasureFeatures(cfg, data);

% Plot microstate transistions
transistionFeatureIndex = strcmp(data.featurelabels, 'statetransitions');
for trli=1:length(data.featurevalues{transistionFeatureIndex})
  transistionMatrix = data.featurevalues{transistionFeatureIndex}{trli};
  fh = PlotMicrostateTransistionMatrix(data.microstateTemplates{trli}, data.label, lay, transistionMatrix);
  set(fh,'Name',sprintf('%i Seconds: Microstate Transistions',intervalLength));
end

