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
cfg.compareto = 'self';
cfg.clusterstatistic = 'roughness';
cfg.sensorneighbors = neighb;
cfg.sensorlabels = data.label;
templateRoughness = TemplateStatistics(microstateTemplates{1}{1}, cfg);
% compute contrast
cfg = [];
cfg.compareto = 'self';
cfg.clusterstatistic = 'spatialcontrast';
cfg.sensorneighbors = neighb;
cfg.sensorlabels = data.label;
templateContrast = TemplateStatistics(microstateTemplates{1}{1}, cfg);

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


