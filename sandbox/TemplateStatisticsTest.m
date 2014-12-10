%% Code to test TemplateStatistics function

clear;

numMicrostates = 8;
fileName = GetLocalDataFile();


% select and open preprocessed HCP MEG data file
load(fileName, 'data');
[~, scanLabel, ~] = fileparts(fileName);

% band filter preprocess
cfg = [];
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg, data);

% Extract microstates
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'global';
microstateTemplates = ExtractMicrostateTemplates(cfg);

%% find microstate sequence in electroneurophys data
cfg = [];
cfg.microstateTemplates = microstateTemplates{1}{1};
data = AssignMicrostateLabels(cfg, data);

% Plot Template Maps
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}, data.label, lay, scanLabel);

%% compute statistics for each template
cfg = [];
cfg.method     = 'distance';
cfg.neighbourdist = 0.035;
cfg.grad       = data.hdr.grad;
neighb         = ft_prepare_neighbours(cfg);
% compute roughness
cfg = [];
cfg.clusterstatistic = 'roughness';
cfg.microstatetemplates = microstateTemplates{1}{1};
cfg.sensorneighbors = neighb;
templateRoughness = TemplateStatistics(cfg, data);
% compute contrast
cfg = [];
cfg.clusterstatistic = 'spatialcontrast';
cfg.microstatetemplates = microstateTemplates{1}{1};
cfg.sensorneighbors = neighb;
templateContrast = TemplateStatistics(cfg, data);
% compute variance
cfg = [];
cfg.clusterstatistic = 'variance';
cfg.microstatetemplates = microstateTemplates{1}{1};
clusterVariance = TemplateStatistics(cfg, data);
% compute normalized standard deviation
cfg = [];
cfg.clusterstatistic = 'standarddeviation';
cfg.microstatetemplates = microstateTemplates{1}{1};
clusterStandardDeviation = TemplateStatistics(cfg, data);

% Plot templates sorted by roughness (ascending)
[~, I] = sort(templateRoughness);
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}(I,:), data.label, lay, ['Ascending Roughness - ' scanLabel]);

% Plot templates sorted by contrast (ascending)
[~, I] = sort(templateContrast);
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}(I,:), data.label, lay, ['Ascending Contrast - ' scanLabel]);

% Plot templates sorted by cluster variance (ascending)
[sortedClusterVariance, I] = sort(clusterVariance);
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}(I,:), data.label, lay, ['Ascending Cluster Variance - ' scanLabel]);


% Plot templates sorted by normalize standard deviation of clusters (ascending)
[sortedClusterStandardDeviation, I] = sort(clusterStandardDeviation);
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}(I,:), data.label, lay, ['Ascending Cluster Standard Deviation (normalized) - ' scanLabel]);


